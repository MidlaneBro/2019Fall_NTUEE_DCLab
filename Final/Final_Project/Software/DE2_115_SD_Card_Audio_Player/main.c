// --------------------------------------------------------------------
// Copyright (c) 2010 by Terasic Technologies Inc.
// --------------------------------------------------------------------
//
// Permission:
//
//   Terasic grants permission to use and modify this code for use
//   in synthesis for all Terasic Development Boards and Altera Development
//   Kits made by Terasic.  Other use of this code, including the selling
//   ,duplication, or modification of any portion is strictly prohibited.
//
// Disclaimer:
//
//   This VHDL/Verilog or C/C++ source code is intended as a design reference
//   which illustrates how these types of functions can be implemented.
//   It is the user's responsibility to verify their design for
//   consistency and functionality through the use of formal
//   verification methods.  Terasic provides no warranty regarding the use
//   or functionality of this code.
//
// --------------------------------------------------------------------
//
//                     Terasic Technologies Inc
//                     356 Fu-Shin E. Rd Sec. 1. JhuBei City,
//                     HsinChu County, Taiwan
//                     302
//
//                     web: http://www.terasic.com/
//                     email: support@terasic.com
//
// --------------------------------------------------------------------

#include ".\terasic_lib\terasic_includes.h"
#include ".\terasic_lib\LED.h"
#include ".\terasic_fat\FatFileSystem.h"
#include ".\terasic_fat\FatInternal.h"
#include ".\terasic_lib\WaveLib.h"
#include ".\terasic_lib\I2C.h"
#include ".\terasic_lib\AUDIO.h"
#include ".\terasic_sdcard\sd_lib.h"

#define SCORER_0_BASE 0x8000


#ifdef DEBUG_APP
    #define APP_DEBUG(x)    DEBUG(x)
#else
    #define APP_DEBUG(x)
#endif

#define DEMO_PRINTF printf

//===== display config =====

#define LCD_DISPLAY
#define SEG7_DISPLAY
#define DISPLAY_WAVE_POWER
#define SUPPORT_PLAY_MODE
#define xENABLE_DEBOUNCE

#ifdef LCD_DISPLAY
    #include ".\terasic_lib\LED.h"
#endif

#ifdef SEG7_DISPLAY
    #include ".\terasic_lib\SEG7.h"
#endif

//===== constance definition =====
#define MAX_VOL 8
#define AUTO_NEXT_SONG
#define HW_MAX_VOL     127
#define HW_MIN_VOL     47
#define HW_DEFAULT_VOL  120

//===== structure definition =====

// return number of wave file
#define MAX_FILE_NUM    128
#define FILENAME_LEN    32

typedef struct{
    int nFileNum;
    char szFilename[MAX_FILE_NUM][FILENAME_LEN];
}WAVE_PLAY_LIST;


static WAVE_PLAY_LIST gWavePlayList;
static WAVE_PLAY_LIST gWavePlayList_bgm;
static WAVE_PLAY_LIST gWavePlayList_vocal;

#define WAVE_BUF_SIZE  512  // do not chagne this constant (FIFO: 4*128 byte)
typedef struct{
    FAT_FILE_HANDLE hFile;
    alt_u8          szBuf[WAVE_BUF_SIZE];  // one sector size of sd-card
    alt_u32         uWavePlayIndex;
    alt_u32         uWaveReadPos;
    alt_u32         uWavePlayPos;
    alt_u32         uWaveMaxPlayPos;
    char szFilename[FILENAME_LEN];
    alt_u8          nVolume;
    bool            bRepeatMode;
    bool            bPlayMode;
}PLAYWAVE_CONTEXT;

static PLAYWAVE_CONTEXT gWavePlay;// = {{0},{0}, HW_DEFAULT_VOL, {0}, 0, 0, 0};
static PLAYWAVE_CONTEXT gWavePlay_vocal;
static FAT_HANDLE hFat;
//static FAT_HANDLE hFat_vocal;
static int nMute_Volume = 0;
static int counter_ch = 0;

//===== function prototype =====
void welcome_display(void);
void update_status(void);
void wait_sdcard_insert(void);
int build_wave_play_list(FAT_HANDLE hFat);
void handle_key(bool *pNexSongPressed, bool *ChangePlayMode, bool *ChangeKaraoke);
void handle_IrDA(bool * pNexSongPressed,alt_u32 id);
void IRDA_init();
bool waveplay_start(char *pFilename, char *pFilename_vocal);
bool waveplay_change_mode(char *pFilename);
bool waveplay_execute(bool *bEOF);
void DisplayTime(alt_u32 TimeElapsed);
void lcd_open(void);
void lcd_display(char *pText);
void led_display(alt_u32 mask);
void led_display_count(alt_u8 count);
bool Fat_Test(FAT_HANDLE hFat, char *pDumpFile);

static bool bLastSwitch = FALSE; //TRUE: handle_IrDA
static bool bNextSwitch = FALSE; //TRUE: handle_IrDA
static bool bMuteSwitch = FALSE;
static bool bPlaySwitch = TRUE;
static bool bKaraoke = FALSE;
static int percent = 0;
static int score = 0;
static int scorer_pointer = 0;
static int scorer_counter = 0;
static int scorer_counter_total = 0;
static int score_total = 0;
static long int ch_vocal_total = 0;
static long int ch_mic_total = 0;

/////////////////////////////////////////////////////////////////
/////////// Display config & function ///////////////////////////
/////////////////////////////////////////////////////////////////



void welcome_display(void){
    int i;
    lcd_display(("\rWelcome Demo\nCDCARD-AUDIO\n"));
    for(i=0;i<5;i++){
        LED_AllOn();
        usleep(50*1000);
        LED_AllOff();
        usleep(50*1000);
    }
}

void demo_introduce(void){
    DEMO_PRINTF("===== Welcome to SD-CARD Demo Program =====\r\n");
    DEMO_PRINTF("Supported File System: FAT16,FAT32, English Short File Name,English Long File Name\r\n");
    DEMO_PRINTF("Played Wave Files: Wave files on root directory.\r\n");
    DEMO_PRINTF("Supported Media File: Uncompressed WAV File, Sample-Rate 96K/48K/44.1K/32K/8K, Stereo, 16-bits Sample.\r\n");
    DEMO_PRINTF("KEY4: Next Song\r\n");
#ifdef SUPPORT_PLAY_MODE
    DEMO_PRINTF("SW0 ON: Enable Repeat Mode\n");
#endif
    DEMO_PRINTF("KEY3: Volume Up\r\n");
    DEMO_PRINTF("KEY2: Volume Down\r\n");
    DEMO_PRINTF("Current Voluem:%d(%d-%d)\r\n\r\n", HW_DEFAULT_VOL, HW_MIN_VOL, HW_MAX_VOL);
}

void update_status(void){
#ifdef LCD_DISPLAY
    char szText[64];
    if(bKaraoke){
    	sprintf(szText,"\rScore:%d\nPercent:%d.%d\n",score,percent/10,percent%10);
    }else{
    	sprintf(szText, "\r%s\nVol:%d(%d-%d)%C\n", gWavePlay.szFilename, gWavePlay.nVolume,
    	        HW_MIN_VOL, HW_MAX_VOL, gWavePlay.bRepeatMode?'R':'S');
    }

    //DEMO_PRINTF("RepeatMode: %d\r\n",gWavePlay.bRepeatMode?"On\n":"Off\n");
    lcd_display((szText));
#endif
}

void DisplayTime(alt_u32 TimeElapsed){
#ifdef SEG7_DISPLAY
    alt_u32 msx10;
    msx10 = TimeElapsed*100/alt_ticks_per_second();
    SEG7_Decimal(msx10, 0x01 << 2);
#endif




}

void lcd_open(void){
#ifdef LCD_DISPLAY
    LCD_Open();
#endif
}

void lcd_display(char *pText){
#ifdef LCD_DISPLAY
    LCD_Clear();
    LCD_TextOut(pText);
#endif
}

void led_display(alt_u32 mask){
#ifdef LCD_DISPLAY
    LED_Display(mask);
#endif
}

void led_display_count(alt_u8 count){
#ifdef DISPLAY_WAVE_POWER
    LED_LightCount(count);
#endif
}


/////////////////////////////////////////////////////////////////
/////////// Routing for detect SD-CARD //////////////////////////
/////////////////////////////////////////////////////////////////

void wait_sdcard_insert(void){
    bool bFirstTime2Detect = TRUE;
    alt_u8 led_mask = 0x02;
    LED_AllOff();
    //led = IORD_ALTERA_AVALON_PIO_DATA(LED_RED_SPAN); // low-active
    while(!SDLIB_Init()){
        if (bFirstTime2Detect){
            DEMO_PRINTF("Please insert SD card.\r\n");
            lcd_display(("\rPlease insert\nSD card.\n"));
            bFirstTime2Detect = FALSE;
        }
        led_display((led_mask));
        usleep(100*1000);
        led_mask ^= 0x02;
    } // while
    led_display((0x02));
    DEMO_PRINTF("Find SD card\r\n");

}

/////////////////////////////////////////////////////////////////
/////////// Routing for building wave-file play list ////////////
/////////////////////////////////////////////////////////////////

bool is_supporrted_sample_rate(int sample_rate){
    bool bSupport = FALSE;
    switch(sample_rate){
        case 96000:
        case 48000:
        case 44100:
        case 32000:
        case 8000:
            bSupport = TRUE;
            break;
    }
    return bSupport;
}


int build_wave_play_list(FAT_HANDLE hFat){
    int count = 0;
    int count_bgm = 0;
    int count_vocal = 0;
    FAT_BROWSE_HANDLE hFileBrowse;
    //FAT_DIRECTORY Directory;
    FILE_CONTEXT FileContext;
    FAT_FILE_HANDLE hFile;
    alt_u8 szHeader[128];
    char szWaveFilename[MAX_FILENAME_LENGTH];
    int sample_rate;
    bool bFlag = FALSE;
    int MusicType = 0;
    int nPos = 0;
    int length=0;
    //
    gWavePlayList.nFileNum = 0;
    if (!Fat_FileBrowseBegin(hFat,&hFileBrowse)){
        DEMO_PRINTF("browse file fail.\n");
        return 0;
    }

    //
    while (Fat_FileBrowseNext(&hFileBrowse,&FileContext)){
    	MusicType = 0;
		if (FileContext.bLongFilename){
			nPos = 0;
			alt_u16 *pData16;
			alt_u8 *pData8;
			pData16 = (alt_u16 *)FileContext.szName;
			pData8 = FileContext.szName;
			while(*pData16){
				if (*pData8 && *pData8 != ' ')
					szWaveFilename[nPos++] = *pData8;
				pData8++;
				if (*pData8 && *pData8 != ' ')
					szWaveFilename[nPos++] = *pData8;
				pData8++;
				//
				pData16++;
			}
			szWaveFilename[nPos] = 0;
			//printf("\n--Music Name:%s --\n",szWaveFilename);
		}else{
			strcpy(szWaveFilename,FileContext.szName);
			//printf("\n--Music Name:%s --\n",FileContext.szName);
		}
		DEMO_PRINTF("szWaveFilename: %s\n",szWaveFilename);
		length= strlen(szWaveFilename);
		if(length>=11){
			if((szWaveFilename[length-6] == 'l' || szWaveFilename[length-6] == 'L')
				&&(szWaveFilename[length-7] == 'a' || szWaveFilename[length-7] == 'A')
				&&(szWaveFilename[length-8] == 'c' || szWaveFilename[length-8] == 'C')
				&&(szWaveFilename[length-9] == 'o' || szWaveFilename[length-9] == 'O')
				&&(szWaveFilename[length-10] == 'v' || szWaveFilename[length-10] == 'V')
				){
					MusicType = 1;
					DEMO_PRINTF("vocal detected.\n");
				}
		}
		if(length>=9){
			if((szWaveFilename[length-6] == 'm' || szWaveFilename[length-6] == 'M')
				&&(szWaveFilename[length-7] == 'g' || szWaveFilename[length-7] == 'G')
				&&(szWaveFilename[length-8] == 'b' || szWaveFilename[length-8] == 'B')
				){
					MusicType = 2;
					DEMO_PRINTF("bgm detected.\n");
				}
		}
		if(length >= 4){
		   if((szWaveFilename[length-1] =='V' || szWaveFilename[length-1] =='v')
			&&(szWaveFilename[length-2] == 'A' || szWaveFilename[length-2] =='a')
			&&(szWaveFilename[length-3] == 'W' || szWaveFilename[length-3] == 'w')
			&&(szWaveFilename[length-4] == '.')){
			   bFlag = TRUE;
			}
		}
		if (bFlag){
			// parsing wave format
			hFile = Fat_FileOpen(hFat,szWaveFilename);
			if (!hFile){
				  DEMO_PRINTF("wave file open fail.\n");
				  continue;
			}
			DEMO_PRINTF("Read OK.\n");

			//memset(szHeader,0,sizeof(szHeader));

			if (!Fat_FileRead(hFile, szHeader, sizeof(szHeader))){
				  DEMO_PRINTF("wave file read fail.\n");
				  continue;
			}
			Fat_FileClose(hFile);

						// check wave format
						/**
			if(!WAVE_IsWaveFile(szHeader, sizeof(szHeader))){
				DEMO_PRINTF("Iswave. \n");
			}
			if(!is_supporrted_sample_rate(sample_rate)){
				DEMO_PRINTF("sample rate supported. \n");
			}
			if(!(Wave_GetChannelNum(szHeader, sizeof(szHeader))==2)){
				DEMO_PRINTF("ChannelNum. \n");
			}
			if(!(Wave_GetSampleBitNum(szHeader, sizeof(szHeader))==16)){
				DEMO_PRINTF("SampleBitNum. \n");
			}
			*/
			sample_rate =  Wave_GetSampleRate(szHeader, sizeof(szHeader));
			if (WAVE_IsWaveFile(szHeader, sizeof(szHeader)) &&
				is_supporrted_sample_rate(sample_rate) &&
				Wave_GetChannelNum(szHeader, sizeof(szHeader))==2 &&
				Wave_GetSampleBitNum(szHeader, sizeof(szHeader))==16){
				int i, j;
				bool tempend = FALSE;
				if(MusicType==0){
					for(i=count-1;i>=0;i--){
						for(j=0;j<((strlen(gWavePlayList.szFilename[i])>strlen(szWaveFilename))? strlen(szWaveFilename): strlen(gWavePlayList.szFilename[i]));j++){
							if(gWavePlayList.szFilename[i][j]==szWaveFilename[j]){

							}else if(gWavePlayList.szFilename[i][j] > szWaveFilename[j]){
								strcpy(gWavePlayList.szFilename[i+1],gWavePlayList.szFilename[i]);
								break;
							}else{
								tempend = TRUE;
								break;
							}
						}
						if(tempend){
							break;
						}
					}

					strcpy(gWavePlayList.szFilename[i+1],szWaveFilename);
					count++;
					//DEMO_PRINTF("count++ \n");
				}else if(MusicType==1){
					for(i=count_vocal-1;i>=0;i--){
						for(j=0;j<((strlen(gWavePlayList_vocal.szFilename[i])>strlen(szWaveFilename))? strlen(szWaveFilename): strlen(gWavePlayList_vocal.szFilename[i]));j++){
							if(gWavePlayList_vocal.szFilename[i][j]==szWaveFilename[j]){

							}else if(gWavePlayList_vocal.szFilename[i][j] > szWaveFilename[j]){
								strcpy(gWavePlayList_vocal.szFilename[i+1],gWavePlayList_vocal.szFilename[i]);
								break;
							}else{
								tempend = TRUE;
								break;
							}
						}
						if(tempend){
							break;
						}
					}

					strcpy(gWavePlayList_vocal.szFilename[i+1],szWaveFilename);
					count_vocal++;
				}else if(MusicType==2){
					for(i=count_bgm-1;i>=0;i--){
						for(j=0;j<((strlen(gWavePlayList_bgm.szFilename[i])>strlen(szWaveFilename))? strlen(szWaveFilename): strlen(gWavePlayList_bgm.szFilename[i]));j++){
							if(gWavePlayList_bgm.szFilename[i][j]==szWaveFilename[j]){

							}else if(gWavePlayList_bgm.szFilename[i][j] > szWaveFilename[j]){
								strcpy(gWavePlayList_bgm.szFilename[i+1],gWavePlayList_bgm.szFilename[i]);
								break;
							}else{
								tempend = TRUE;
								break;
							}
						}
						if(tempend){
							break;
						}
					}

					strcpy(gWavePlayList_bgm.szFilename[i+1],szWaveFilename);
					count_bgm++;
				}
			}
		}
    } // while
    gWavePlayList.nFileNum = count;
    gWavePlayList_bgm.nFileNum = count_bgm;
    gWavePlayList_vocal.nFileNum = count_vocal;
    DEMO_PRINTF("count: %d\n", count);
    DEMO_PRINTF("count_bgm: %d\n", count_bgm);
    DEMO_PRINTF("count_vocal: %d \n", count_vocal);
    int i;
    for(i=0;i<count;i++){
    	DEMO_PRINTF("%s", gWavePlayList.szFilename[i]);
    	DEMO_PRINTF(", %s", gWavePlayList_bgm.szFilename[i]);
    	DEMO_PRINTF(", %s\n", gWavePlayList_vocal.szFilename[i]);
    }

    //Fat_FileBrowseEnd(&hFileBrowse);

    return count;
}




/////////////////////////////////////////////////////////////////
//// Function for wave playing /////////////////////////////////
/////////////////////////////////////////////////////////////////



void waveplay_stop(void);

bool waveplay_start(char *pFilename, char *pFilename_vocal){
    bool bSuccess;
    int nSize;
    //waveplay_stop();

  //  strcpyn(gWavePlay.szFilename, pFilename, FILENAME_LEN-1);
    strcpy(gWavePlay.szFilename, pFilename);
    gWavePlay.hFile = Fat_FileOpen(hFat, pFilename);
    if (!gWavePlay.hFile)
        DEMO_PRINTF("wave file open fail.\n");

    //gWavePlay.szBuf = Fat_FileSize(gWavePlay.hFile);
    nSize = Fat_FileSize(gWavePlay.hFile);

    if (gWavePlay.hFile){
        bSuccess = Fat_FileRead(gWavePlay.hFile, gWavePlay.szBuf, WAVE_BUF_SIZE);
        if (!bSuccess)
            DEMO_PRINTF("wave file read fail.\n");
    }

                        // check wave format
    if (bSuccess){
            int sample_rate =  Wave_GetSampleRate(gWavePlay.szBuf, WAVE_BUF_SIZE);
            if (WAVE_IsWaveFile(gWavePlay.szBuf, WAVE_BUF_SIZE) &&
                is_supporrted_sample_rate(sample_rate) &&
                Wave_GetChannelNum(gWavePlay.szBuf, WAVE_BUF_SIZE)==2 &&
                Wave_GetSampleBitNum(gWavePlay.szBuf, WAVE_BUF_SIZE)==16){

                gWavePlay.uWavePlayPos = Wave_GetWaveOffset(gWavePlay.szBuf, WAVE_BUF_SIZE);
                gWavePlay.uWaveMaxPlayPos = gWavePlay.uWavePlayPos + Wave_GetDataByteSize(gWavePlay.szBuf, WAVE_BUF_SIZE);
                gWavePlay.uWaveReadPos = WAVE_BUF_SIZE;

                DEMO_PRINTF("gWavePlay.uWavePlayPos:%x\n",gWavePlay.uWavePlayPos);
                DEMO_PRINTF("gWavePlay.uWaveMaxPlayPos:%x\n",gWavePlay.uWaveMaxPlayPos);
                DEMO_PRINTF("gWavePlay.uWaveReadPos:%x\n",gWavePlay.uWaveReadPos);

                // setup sample rate
                AUDIO_InterfaceActive(FALSE);
                if (sample_rate == 96000)
                    AUDIO_SetSampleRate(RATE_ADC96K_DAC96K);
                else if (sample_rate == 48000)
                    AUDIO_SetSampleRate(RATE_ADC48K_DAC48K);
                else if (sample_rate == 44100)
                    AUDIO_SetSampleRate(RATE_ADC44K1_DAC44K1);
                else if (sample_rate == 32000)
                    AUDIO_SetSampleRate(RATE_ADC32K_DAC32K);
                else if (sample_rate == 8000)
                    AUDIO_SetSampleRate(RATE_ADC8K_DAC8K);
                else
                    DEMO_PRINTF("unsupported sample rate=%d\n", sample_rate);
                AUDIO_FifoClear();
                AUDIO_InterfaceActive(TRUE);


                DEMO_PRINTF("sample rate=%d\n", sample_rate);
            }else{
                bSuccess = FALSE;
            }
    }

    if(bKaraoke){
    	strcpy(gWavePlay_vocal.szFilename, pFilename_vocal);
    	DEMO_PRINTF("(vocal) filename:%s\n",pFilename_vocal);
		gWavePlay_vocal.hFile = Fat_FileOpen(hFat, pFilename_vocal);
		if (!gWavePlay_vocal.hFile)
			DEMO_PRINTF("(vocal) wave file open fail.\n");

		//gWavePlay.szBuf = Fat_FileSize(gWavePlay.hFile);
		nSize = Fat_FileSize(gWavePlay_vocal.hFile);

		if (gWavePlay_vocal.hFile){
			bSuccess = Fat_FileRead(gWavePlay_vocal.hFile, gWavePlay_vocal.szBuf, WAVE_BUF_SIZE);
			if (!bSuccess)
				DEMO_PRINTF("(vocal) wave file read fail.\n");
		}

							// check wave format
		if (bSuccess){
			int sample_rate =  Wave_GetSampleRate(gWavePlay_vocal.szBuf, WAVE_BUF_SIZE);
			if (WAVE_IsWaveFile(gWavePlay_vocal.szBuf, WAVE_BUF_SIZE) &&
				is_supporrted_sample_rate(sample_rate) &&
				Wave_GetChannelNum(gWavePlay_vocal.szBuf, WAVE_BUF_SIZE)==2 &&
				Wave_GetSampleBitNum(gWavePlay_vocal.szBuf, WAVE_BUF_SIZE)==16){

				gWavePlay_vocal.uWavePlayPos = Wave_GetWaveOffset(gWavePlay_vocal.szBuf, WAVE_BUF_SIZE);
				gWavePlay_vocal.uWaveMaxPlayPos = gWavePlay_vocal.uWavePlayPos + Wave_GetDataByteSize(gWavePlay_vocal.szBuf, WAVE_BUF_SIZE);
				gWavePlay_vocal.uWaveReadPos = WAVE_BUF_SIZE;

				DEMO_PRINTF("(vocal)gWavePlay.uWavePlayPos:%x\n",gWavePlay_vocal.uWavePlayPos);
				DEMO_PRINTF("(vocal)gWavePlay.uWaveMaxPlayPos:%x\n",gWavePlay_vocal.uWaveMaxPlayPos);
				DEMO_PRINTF("(vocal)gWavePlay.uWaveReadPos:%x\n",gWavePlay_vocal.uWaveReadPos);

			}else{
				bSuccess = FALSE;
			}
		}
    }
    if (!bSuccess)
        waveplay_stop();

    return bSuccess;
}
bool waveplay_change_mode(char *pFilename){
    bool bSuccess;
    int nSize;
    alt_u32 tempwaveoffset = Wave_GetWaveOffset(gWavePlay.szBuf, WAVE_BUF_SIZE);
    //waveplay_stop();

  //  strcpyn(gWavePlay.szFilename, pFilename, FILENAME_LEN-1);
    strcpy(gWavePlay.szFilename, pFilename);
    gWavePlay.hFile = Fat_FileOpen(hFat, pFilename);
    if (!gWavePlay.hFile)
        DEMO_PRINTF("wave file open fail.\n");

    //gWavePlay.szBuf = Fat_FileSize(gWavePlay.hFile);
    nSize = Fat_FileSize(gWavePlay.hFile);

    if (gWavePlay.hFile){
        bSuccess = Fat_FileRead(gWavePlay.hFile, gWavePlay.szBuf, WAVE_BUF_SIZE);
        if (!bSuccess)
            DEMO_PRINTF("wave file read fail.\n");
    }

                        // check wave format
    if (bSuccess){
            int sample_rate =  Wave_GetSampleRate(gWavePlay.szBuf, WAVE_BUF_SIZE);
            if (WAVE_IsWaveFile(gWavePlay.szBuf, WAVE_BUF_SIZE) &&
                is_supporrted_sample_rate(sample_rate) &&
                Wave_GetChannelNum(gWavePlay.szBuf, WAVE_BUF_SIZE)==2 &&
                Wave_GetSampleBitNum(gWavePlay.szBuf, WAVE_BUF_SIZE)==16){


                //gWavePlay.uWavePlayPos = gWavePlay.uWavePlayPos+Wave_GetWaveOffset(gWavePlay.szBuf, WAVE_BUF_SIZE);
                gWavePlay.uWaveMaxPlayPos = gWavePlay.uWavePlayPos + Wave_GetDataByteSize(gWavePlay.szBuf, WAVE_BUF_SIZE);

                DEMO_PRINTF("test.\n");
                // setup sample rate
                AUDIO_InterfaceActive(FALSE);
                if (sample_rate == 96000)
                    AUDIO_SetSampleRate(RATE_ADC96K_DAC96K);
                else if (sample_rate == 48000)
                    AUDIO_SetSampleRate(RATE_ADC48K_DAC48K);
                else if (sample_rate == 44100)
                    AUDIO_SetSampleRate(RATE_ADC44K1_DAC44K1);
                else if (sample_rate == 32000)
                    AUDIO_SetSampleRate(RATE_ADC32K_DAC32K);
                else if (sample_rate == 8000)
                    AUDIO_SetSampleRate(RATE_ADC8K_DAC8K);
                else
                    DEMO_PRINTF("unsupported sample rate=%d\n", sample_rate);
                AUDIO_FifoClear();
                AUDIO_InterfaceActive(TRUE);


                DEMO_PRINTF("sample rate=%d\n", sample_rate);
            }else{
                bSuccess = FALSE;
            }
    }

    if (!bSuccess)
        waveplay_stop();

    return bSuccess;
}

bool waveplay_execute(bool *bEOF){
    bool bSuccess = TRUE;
    bool bDataReady = FALSE;


    // end of play data !
    if (gWavePlay.uWavePlayPos >= gWavePlay.uWaveMaxPlayPos){
    	DEMO_PRINTF("song finished\n");
        *bEOF = TRUE;
        IOWR(SCORER_0_BASE, 3, 0xFF);
        bKaraoke = FALSE;
        return TRUE;
    }

    //
    *bEOF = FALSE;
    while (!bDataReady && bSuccess){
    	if(bKaraoke){
    		if ((gWavePlay.uWavePlayPos < gWavePlay.uWaveReadPos)){
    			if(gWavePlay_vocal.uWavePlayPos < gWavePlay_vocal.uWaveReadPos){
    				bDataReady = TRUE;
    				//DEBUG_PRINTF("it is not neccessary to read data from sd-card\r\n");
    			}else{
    				int read_size = WAVE_BUF_SIZE;
					if (read_size > (gWavePlay_vocal.uWaveMaxPlayPos - gWavePlay_vocal.uWavePlayPos))
						read_size = gWavePlay_vocal.uWaveMaxPlayPos - gWavePlay_vocal.uWavePlayPos;
					bSuccess = Fat_FileRead(gWavePlay_vocal.hFile, gWavePlay_vocal.szBuf, read_size);
					if (bSuccess)
						gWavePlay_vocal.uWaveReadPos += read_size;
					else
						DEMO_PRINTF("[APP](vocal)sdcard read fail, read_pos:%ld, read_size:%d, max_play_pos:%ld !\r\n", gWavePlay_vocal.uWaveReadPos, read_size, gWavePlay_vocal.uWaveMaxPlayPos);
					/*
					DEMO_PRINTF("(vocal)gWavePlay.uWavePlayPos:%x\n",gWavePlay_vocal.uWavePlayPos);
					DEMO_PRINTF("(vocal)gWavePlay.uWaveMaxPlayPos:%x\n",gWavePlay_vocal.uWaveMaxPlayPos);
					DEMO_PRINTF("(vocal)gWavePlay.uWaveReadPos:%x\n",gWavePlay_vocal.uWaveReadPos);
					*/
    			}
			}else{
				int read_size = WAVE_BUF_SIZE;
				if (read_size > (gWavePlay.uWaveMaxPlayPos - gWavePlay.uWavePlayPos))
					read_size = gWavePlay.uWaveMaxPlayPos - gWavePlay.uWavePlayPos;
				bSuccess = Fat_FileRead(gWavePlay.hFile, gWavePlay.szBuf, read_size);
				if (bSuccess)
					gWavePlay.uWaveReadPos += read_size;
				else
					DEMO_PRINTF("[APP]sdcard read fail, read_pos:%ld, read_size:%d, max_play_pos:%ld !\r\n", gWavePlay.uWaveReadPos, read_size, gWavePlay.uWaveMaxPlayPos);
				/*
				DEMO_PRINTF("gWavePlay.uWavePlayPos:%x\n",gWavePlay.uWavePlayPos);
				DEMO_PRINTF("gWavePlay.uWaveMaxPlayPos:%x\n",gWavePlay.uWaveMaxPlayPos);
				DEMO_PRINTF("gWavePlay.uWaveReadPos:%x\n",gWavePlay.uWaveReadPos);
				*/
			}
    	}else{
    		if ((gWavePlay.uWavePlayPos < gWavePlay.uWaveReadPos)){
    			bDataReady = TRUE;
				//DEBUG_PRINTF("it is not neccessary to read data from sd-card\r\n");
			}else{
				int read_size = WAVE_BUF_SIZE;
				if (read_size > (gWavePlay.uWaveMaxPlayPos - gWavePlay.uWavePlayPos))
					read_size = gWavePlay.uWaveMaxPlayPos - gWavePlay.uWavePlayPos;
				bSuccess = Fat_FileRead(gWavePlay.hFile, gWavePlay.szBuf, read_size);
				if (bSuccess)
					gWavePlay.uWaveReadPos += read_size;
				else
					DEMO_PRINTF("[APP]sdcard read fail, read_pos:%ld, read_size:%d, max_play_pos:%ld !\r\n", gWavePlay.uWaveReadPos, read_size, gWavePlay.uWaveMaxPlayPos);
			}
    	}

    } // while

    //
    if (bDataReady && bSuccess){
#ifdef DISPLAY_WAVE_POWER
        alt_u32 power_sum = 0, power;
#endif
        int play_size;
        short *pSample = (short *)(gWavePlay.szBuf + gWavePlay.uWavePlayPos%WAVE_BUF_SIZE);
        short *pSample_vocal;
        if(bKaraoke){
        	pSample_vocal = (short *)(gWavePlay_vocal.szBuf + gWavePlay_vocal.uWavePlayPos%WAVE_BUF_SIZE);
        }
        int i = 0;
        play_size = gWavePlay.uWaveReadPos - gWavePlay.uWavePlayPos;
        play_size = play_size/4*4;
        while(i < play_size){
            if(AUDIO_DacFifoNotFull()){ // if audio ready (not full)
            	if(bKaraoke){
            		if(AUDIO_AdcFifoNotEmpty()){
						short ch_right, ch_left;
						short ch_right_vocal, ch_left_vocal;
						short ch_right_mic;
						short ch_left_mic;
						ch_left = *pSample++;
						ch_right = *pSample++;
						ch_left_vocal = *pSample_vocal++;
						ch_right_vocal = *pSample_vocal++;
						AUDIO_AdcFifoGetData(&ch_left_mic, &ch_right_mic);
#ifdef DISPLAY_WAVE_POWER  // indicate power by avg 64 sample
						power = abs(ch_left) + abs(ch_right);
						power_sum += power;
						if ((i & 0x01F) == 0 && i != 0){
							power = power_sum >> (6+7);  // 6: divide 64,  7: power scale
							led_display_count(power);
							power_sum = 0;
						}
#endif
						int ch_vocal = (ch_left_vocal << 16)+ch_right_vocal;
						int ch_mic = (ch_left_mic << 16)+ch_right_mic;
						if(counter_ch==20000){
							//DEMO_PRINTF("ch_left_mic:%d\n",ch_left_mic);
							//DEMO_PRINTF("ch_right_mic:%d\n",ch_right_mic);
							update_status();
							counter_ch = 0;
							counter_ch ++;
						}else{
							counter_ch ++;
						}
						if(scorer_pointer==2048){
							alt_32 mask_score = 0x0000FFFF << 16;
							alt_32 mask_percent = 0x000003FF << 6;
							//alt_32 temp_read = IORD(SCORER_0_BASE,2);//score 31:16 percent 15:6
							//DEMO_PRINTF("temp_read:%x\n",temp_read);
							//percent = ((temp_read & mask_percent) >> 6);
							//score = ((temp_read & mask_score) >> 16);
							scorer_pointer = 0;
							//score = score+1;

						}
						//???q score
						ch_vocal_total += (abs(ch_left_vocal)+abs(ch_right_vocal))/2;
						ch_mic_total += (abs(ch_left_mic)+abs(ch_right_mic))/2;
						/*
						if(abs((ch_left_vocal+ch_right_vocal)/2)>1200){
							if((ch_left_vocal+ch_right_vocal)/2>=0 &&((ch_left_mic+ch_right_mic)/2-(ch_left_vocal+ch_right_vocal)/2<300)&&((ch_left_mic+ch_right_mic)/2-(ch_left_vocal+ch_right_vocal)/2>-200)){
								scorer_counter ++;
							}else if(((ch_left_mic+ch_right_mic)/2-(ch_left_vocal+ch_right_vocal)/2 < -300)&&((ch_left_mic+ch_right_mic)/2-(ch_left_vocal+ch_right_vocal)/2 > 200)){
								scorer_counter ++;
							}
							scorer_counter_total++;
						}
						if(scorer_counter==100){
							scorer_counter = 0;
							score++;
							//DEMO_PRINTF("ratio:%e\n",ratio);
							percent = (score*1000/score_total);
						}
						if(scorer_counter_total==100){
							scorer_counter_total = 0;
							score_total++;
						}
						*/

						if(scorer_counter==100){
							if(abs(ch_vocal_total/100)>900){
								if(((ch_mic_total/100-ch_vocal_total/100)<1000)&&((ch_mic_total/100-ch_vocal_total/100)>-200)){
									score++;
								}
								score_total++;
								percent = (score*1000/score_total);
							}
							//DEMO_PRINTF("ratio:%e\n",ratio);
							scorer_counter = 0;
							ch_mic_total = 0;
							ch_vocal_total = 0;
						}

						/*
						IOWR(SCORER_0_BASE,0,ch_mic);
						if(counter_ch==10000){
							DEMO_PRINTF("write_mic:%d\n",ch_left_mic+ch_right_mic);
							DEMO_PRINTF("read_mic:%d\n",IORD(SCORER_0_BASE,0));
						}
						IOWR(SCORER_0_BASE,1,ch_vocal); 
						if(counter_ch==10000){
							DEMO_PRINTF("write_vocal:%d\n",ch_left_vocal+ch_right_vocal);
							DEMO_PRINTF("read_vocal:%d\n",IORD(SCORER_0_BASE,1));
						}
						*/
						scorer_counter++;
						scorer_pointer++;

						/*
						short output_left = ch_left + ch_left_mic;
						short output_right = ch_right + ch_right_mic;
						*/
						//AUDIO_DacFifoSetData(ch_left, ch_right); // play wave
						AUDIO_DacFifoSetData(ch_left+ch_left_mic, ch_right+ch_right_mic); // play wave
						i+=4;
            		}
            	}else{
            		short ch_right, ch_left;

					ch_left = *pSample++;
					ch_right = *pSample++;

#ifdef DISPLAY_WAVE_POWER  // indicate power by avg 64 sample
					power = abs(ch_left) + abs(ch_right);
					power_sum += power;
					if ((i & 0x01F) == 0 && i != 0){
						power = power_sum >> (6+7);  // 6: divide 64,  7: power scale
						led_display_count(power);
						power_sum = 0;
					}
#endif

					AUDIO_DacFifoSetData(ch_left, ch_right); // play wave
					i+=4;
            	}
            }
        } // while
        gWavePlay.uWavePlayPos += play_size;
        gWavePlay_vocal.uWavePlayPos += play_size;

    } //

    return bSuccess;
}

void waveplay_stop(void){
    /*if (gWavePlay.hFile.IsOpened){
        Fat_FileClose(&gWavePlay.hFile);
    }*/
}

/////////////////////////////////////////////////////////////////
/////////// Routing for button handle ///////////////////////////
/////////////////////////////////////////////////////////////////
// return true if next-song
void handle_key(bool *pNexSongPressed, bool *ChangePlayMode, bool *ChangeKaraoke){
    static bool bFirsTime2SetupVol = TRUE;
    alt_u8 button;
    bool bNextSong, bVolUp, bVolDown, bKaraokeChange;
    int nHwVol;


#ifdef SUPPORT_PLAY_MODE
    bool bRepeat;
    bool bPlayMode;
    bool PlayModechange;
    bRepeat = (IORD_ALTERA_AVALON_PIO_DATA(SW_BASE) & 0x01)?TRUE:FALSE;
    bPlayMode = (IORD_ALTERA_AVALON_PIO_DATA(SW_BASE) & 0x02)?TRUE:FALSE;
    if (bRepeat ^ gWavePlay.bRepeatMode){
        gWavePlay.bRepeatMode = bRepeat;
        update_status();
    }
    PlayModechange = bPlayMode ^ gWavePlay.bPlayMode;
    if(PlayModechange){
    	gWavePlay.bPlayMode = bPlayMode;
    	if(bPlayMode)
    		DEMO_PRINTF("change to bgm mode... \r\n");
    	else{
    		DEMO_PRINTF("change to song mode... \r\n");
    	}
    	*ChangePlayMode = PlayModechange;
    }
#endif


    *pNexSongPressed = FALSE;
#ifdef ENABLE_DEBOUNCE
    static alt_u32 next_active_time = 0;
    if (alt_nticks() < next_active_time ){
        return;
    }
    next_active_time = alt_nticks();
#endif

    button = IORD_ALTERA_AVALON_PIO_DATA(KEY_BASE);
    button = IORD_ALTERA_AVALON_PIO_EDGE_CAP(KEY_BASE);
    IOWR_ALTERA_AVALON_PIO_EDGE_CAP(KEY_BASE, 0); // clear flag
    bNextSong = (button & 0x08)?TRUE:FALSE;
    bVolUp = (button & 0x04)?TRUE:FALSE;
    bVolDown = (button & 0x02)?TRUE:FALSE;
    bKaraokeChange = (button & 0x01)?TRUE:FALSE;
    *ChangeKaraoke = bKaraokeChange;
    // adjust volument
    if ((bVolUp || bVolDown || bFirsTime2SetupVol || bKaraokeChange) && !bMuteSwitch){
        nHwVol = gWavePlay.nVolume;
        if (bFirsTime2SetupVol){
            bFirsTime2SetupVol = FALSE;
            DEMO_PRINTF("current volume %d(%d-%d)\r\n", nHwVol, HW_MIN_VOL, HW_MAX_VOL);
        }else if (bVolUp){
            if (nHwVol < HW_MAX_VOL)
                nHwVol++;
            DEMO_PRINTF("volume up %d(%d-%d)\r\n", nHwVol, HW_MIN_VOL, HW_MAX_VOL);
        }else{
            if (nHwVol > HW_MIN_VOL)
                nHwVol--;
            DEMO_PRINTF("volume down %d(%d-%d)\r\n", nHwVol, HW_MIN_VOL, HW_MAX_VOL);
        }
        AUDIO_SetLineOutVol(nHwVol, nHwVol);
        gWavePlay.nVolume = nHwVol;
        if(bKaraokeChange){
        	bKaraoke = !bKaraoke;
        	if(bKaraoke){
        		DEMO_PRINTF("Start Karaoke...\r\n");
        	}else{
        		DEMO_PRINTF("Stop Karaoke...\r\n");
        	}
        }
        update_status();
    }


    if (bNextSong){
        *pNexSongPressed = TRUE;
        DEMO_PRINTF("Play Next Song\r\n");
    }

#ifdef ENABLE_DEBOUNCE
    if (bNextSong || bVolUp || bVolDown){
        next_active_time +=  alt_ticks_per_second()/5;  // debounce
    }
#endif

}

/////////////////////////////////////////////////////////////////
/////////// Routing for IrDA handle /////////////////////////////
/////////////////////////////////////////////////////////////////

//IRDA  initial
void IRDA_init()
{
    alt_irq_register(TERASIC_IRDA_0_IRQ,0,handle_IrDA);            //irda irq register
    alt_irq_enable_all(TERASIC_IRDA_0_IRQ);
    IOWR(TERASIC_IRDA_0_BASE,0,0);
}

// return true if next-song
void handle_IrDA(bool * p,alt_u32 id){
    static bool bFirsTime2SetupVol = TRUE;
    alt_u32 button;
    bool bLastSong,bNextSong, bVolUp, bVolDown,bMute,bPlay;
    int nHwVol;


#ifdef SUPPORT_PLAY_MODE
    bool bRepeat;
    bRepeat = (IORD_ALTERA_AVALON_PIO_DATA(SW_BASE) & 0x01)?TRUE:FALSE;
    if (bRepeat ^ gWavePlay.bRepeatMode){
        gWavePlay.bRepeatMode = bRepeat;
        update_status();
    }
#endif

#ifdef ENABLE_DEBOUNCE
    static alt_u32 next_active_time = 0;
    if (alt_nticks() < next_active_time ){
        return;
    }
    next_active_time = alt_nticks();
#endif

    button = IORD(TERASIC_IRDA_0_BASE,0);
    button <<= 8;
    button >>= 24;
    IOWR_ALTERA_AVALON_PIO_EDGE_CAP(TERASIC_IRDA_0_BASE, 0); // clear flag

    IOWR(TERASIC_IRDA_0_BASE,0,0);
    bLastSong = (button == 0x1a) ? TRUE : FALSE;
    bNextSong = (button == 0x1e) ? TRUE : FALSE;
    bVolUp    = (button == 0x1b) ? TRUE : FALSE;
    bVolDown  = (button == 0x1f) ? TRUE : FALSE;
    bMute     = (button == 0x0c) ? TRUE : FALSE;
    bPlay     = (button == 0x16) ? TRUE : FALSE;


    // adjust volument
    if ((bVolUp || bVolDown || bFirsTime2SetupVol) && !bMuteSwitch){
        nHwVol = gWavePlay.nVolume;
        if (bFirsTime2SetupVol){
            bFirsTime2SetupVol = FALSE;
            DEMO_PRINTF("current volume %d(%d-%d)\r\n", nHwVol, HW_MIN_VOL, HW_MAX_VOL);
        }else if (bVolUp){
            if (nHwVol < HW_MAX_VOL)
                nHwVol++;
            DEMO_PRINTF("volume up %d(%d-%d)\r\n", nHwVol, HW_MIN_VOL, HW_MAX_VOL);
        }else{
            if (nHwVol > HW_MIN_VOL)
                nHwVol--;
            DEMO_PRINTF("volume down %d(%d-%d)\r\n", nHwVol, HW_MIN_VOL, HW_MAX_VOL);
        }
        AUDIO_SetLineOutVol(nHwVol, nHwVol);
        gWavePlay.nVolume = nHwVol;
        update_status();
    }

    if (bLastSong){
        bLastSwitch = TRUE ;
        DEMO_PRINTF("Play Last Song\r\n");
    }
    if (bNextSong){
        bNextSwitch = TRUE ;
        DEMO_PRINTF("Play Next Song\r\n");
    }

    if(bMute){
        nHwVol = gWavePlay.nVolume;
        if(nHwVol != 47){
            nMute_Volume = nHwVol;
            nHwVol = 47;
            DEMO_PRINTF("Open Mute...\r\n");

            bMuteSwitch = TRUE;
        }else{
            nHwVol = nMute_Volume;
            DEMO_PRINTF("Shut Mute...\r\n");

            bMuteSwitch = FALSE;
        }
        AUDIO_SetLineOutVol(nHwVol, nHwVol);
        gWavePlay.nVolume = nHwVol;
        update_status();

    }
    if(bPlay){
        bPlaySwitch = !bPlaySwitch;
        if(bPlaySwitch)
           printf("Play Continue...\r\n");
        else
           printf("Play Pause...\r\n");
        AUDIO_InterfaceActive(bPlaySwitch);
    }
#ifdef ENABLE_DEBOUNCE
    if (bLastSong || bNextSong || bVolUp || bVolDown){
        next_active_time +=  alt_ticks_per_second()/5;  // debounce
    }
#endif

}

bool Fat_Test(FAT_HANDLE hFat, char *pDumpFile){
    bool bSuccess;
    int nCount = 0;
    FAT_BROWSE_HANDLE hBrowse;
    FILE_CONTEXT FileContext;

    bSuccess = Fat_FileBrowseBegin(hFat, &hBrowse);
    if (bSuccess){
        while(Fat_FileBrowseNext(&hBrowse, &FileContext)){
            if (FileContext.bLongFilename){
                alt_u16 *pData16;
                alt_u8 *pData8;
                pData16 = (alt_u16 *)FileContext.szName;
                pData8 = FileContext.szName;
                printf("[%d]", nCount);
                while(*pData16){
                    if (*pData8)
                        printf("%c", *pData8);
                    pData8++;
                    if (*pData8)
                        printf("%c", *pData8);
                    pData8++;
                    //
                    pData16++;
                }
                printf("\n");
            }else{
                printf("---[%d]%s\n", nCount, FileContext.szName);
            }
            nCount++;
        }
    }
    if (bSuccess && pDumpFile && strlen(pDumpFile)){
        FAT_FILE_HANDLE hFile;
        hFile =  Fat_FileOpen(hFat, pDumpFile);
        if (hFile){
            char szRead[256];
            int nReadSize, nFileSize, nTotalReadSize=0;
            nFileSize = Fat_FileSize(hFile);
            if (nReadSize > sizeof(szRead))
                nReadSize = sizeof(szRead);
            printf("%s dump:\n", pDumpFile);
            while(bSuccess && nTotalReadSize < nFileSize){
                nReadSize = sizeof(szRead);
                if (nReadSize > (nFileSize - nTotalReadSize))
                    nReadSize = (nFileSize - nTotalReadSize);
                //
                if (Fat_FileRead(hFile, szRead, nReadSize)){
                    int i;
                    for(i=0;i<nReadSize;i++){
                        printf("%c", szRead[i]);
                    }
                    nTotalReadSize += nReadSize;
                }else{
                    bSuccess = FALSE;
                    printf("\nFaied to read the file \"%s\"\n", pDumpFile);
                }
            } // while
            if (bSuccess)
                printf("\n");
            Fat_FileClose(hFile);
        }else{
            bSuccess = FALSE;
            printf("Cannot find the file \"%s\"\n", pDumpFile);
        }
    }

    return bSuccess;
}

int main()
{
    int nPlayIndex;
    alt_u32 cnt, uSongStartTime, uTimeElapsed;
    alt_8 led_mask = 0x03;
    alt_u8 szWaveFile[FILENAME_LEN];
    alt_u8 szWaveFile_vocal[FILENAME_LEN];
    IRDA_init();
    lcd_open();
    welcome_display();
    demo_introduce();
    if (!AUDIO_Init()){
        DEMO_PRINTF("Audio Init fail!\n");
        lcd_display(("Audio Init fail!\n\n"));
        return 0;
    }

    if(!AUDIO_SetInputSource(SOURCE_MIC)){
    	DEMO_PRINTF("AUDIO_SetInputSource fail!\n");
    }
    /*
    if(!AUDIO_MicMute(FALSE)){
    	DEMO_PRINTF("AUDIO_MicMute False fail!\n");
    }
    AUDIO_MicBoost(TRUE);
    AUDIO_SetLineInVol(gWavePlay.nVolume,gWavePlay.nVolume);
    */
    //AUDIO_EnableByPass(TRUE);
    //AUDIO_EnableSiteTone(TRUE);
    //AUDIO_EnableSiteTone(FALSE);

    memset(&gWavePlay, 0, sizeof(gWavePlay));
    gWavePlay.nVolume = HW_DEFAULT_VOL;
    AUDIO_SetLineOutVol(gWavePlay.nVolume, gWavePlay.nVolume);

    while(1){

        // check SD card
        wait_sdcard_insert();

        // Mount SD-CARD
        hFat = Fat_Mount(FAT_SD_CARD, 0);
        //hFat_vocal = Fat_Mount(FAT_SD_CARD, 0);
        if (!hFat){
            DEMO_PRINTF("SD card mount fail.\n");
            lcd_display(("SD card mount fail.\n\n"));
            return 0;
        }
        else{
           if (build_wave_play_list(hFat) == 0){
            DEMO_PRINTF("(test)There is no wave file in the root directory of SD card.\n");
            lcd_display(("No Wave Files.\n\n"));
            return 0;
            }
        }
        /*
        if (!hFat_vocal){
			DEMO_PRINTF("SD card mount fail.\n");
			lcd_display(("SD card mount fail.\n\n"));
			return 0;
		}
		else{
		   if (build_wave_play_list(hFat_vocal) == 0){
			DEMO_PRINTF("(test)There is no wave file in the root directory of SD card.\n");
			lcd_display(("No Wave Files.\n\n"));
			return 0;
			}
		}
		*/


        bool bSdacrdReady = TRUE;
        nPlayIndex = 0;
        while(bSdacrdReady){
            // find a wave file
            bool bPlayDone = FALSE;
            if((IORD_ALTERA_AVALON_PIO_DATA(SW_BASE) & 0x02)?TRUE:FALSE){
            	strcpy(szWaveFile, gWavePlayList_bgm.szFilename[nPlayIndex]);
            }else{
            	strcpy(szWaveFile, gWavePlayList.szFilename[nPlayIndex]);
            }
            strcpy(szWaveFile_vocal, gWavePlayList_vocal.szFilename[nPlayIndex]);
            DEMO_PRINTF("Play Song:%s\r\n", szWaveFile);
            if (!waveplay_start(szWaveFile, szWaveFile_vocal)){
                DEMO_PRINTF("waveplay_start error\r\n");
                lcd_display("Play Error.\n\n");
                bSdacrdReady = FALSE;
            }
            if(bKaraoke){
            	DEMO_PRINTF("Karaoke Start!");
            }
            update_status();
            cnt = 0;
            uSongStartTime = alt_nticks();
            /**
            DEMO_PRINTF("BeforePlay\n");
			DEMO_PRINTF("bSdacrdReady:%d\n",TRUE);
			DEMO_PRINTF("bEndOfFile:%d\n",FALSE);
			DEMO_PRINTF("bLastSongPressed:%d\n",FALSE);
			DEMO_PRINTF("bNextSongPressed:%d\n",FALSE);
			*/
            while(!bPlayDone && bSdacrdReady){
                bool bLastSongPressed  = FALSE;
                bool bNextSongPressed  = FALSE;
                bool bEndOfFile = FALSE;
                bool ChangePlayMode = FALSE;
                bool ChangeKaraoke = FALSE;
                if ((cnt++ & 0x1F) == 0){
                    led_display(led_mask);
                    led_mask ^= 0x01;
                }

                // play wave file
                if (!waveplay_execute(&bEndOfFile)){
                    DEMO_PRINTF("waveplay_execute error\r\n");
                    lcd_display("Play Error.\n\n");
                    bSdacrdReady = FALSE;
                }

                // handle key event
                handle_key(&bNextSongPressed, &ChangePlayMode, &ChangeKaraoke);

                if(ChangePlayMode){
                	//DEMO_PRINTF("ChangePlayMode\r\n");
                	uSongStartTime = alt_nticks();
                	waveplay_stop();
					if(gWavePlay.bPlayMode){
						if(!waveplay_start(gWavePlayList_bgm.szFilename[nPlayIndex],gWavePlayList_vocal.szFilename[nPlayIndex])){
							DEMO_PRINTF("waveplay_change_mode error\r\n");
							lcd_display("ChangeMode Error.\n\n");
							bSdacrdReady = FALSE;
						}
					}else{
						if(!waveplay_start(gWavePlayList.szFilename[nPlayIndex],gWavePlayList_vocal.szFilename[nPlayIndex])){
							DEMO_PRINTF("waveplay_change_mode error\r\n");
							lcd_display("ChangeMode Error.\n\n");
							bSdacrdReady = FALSE;
						}
					}
					ChangePlayMode = FALSE;
					update_status();
				}else if(ChangeKaraoke){
					waveplay_stop();
					score = 0;
					percent = 0;
					score_total = 0;
					ch_mic_total = 0;
					ch_vocal_total = 0;
					IOWR(SCORER_0_BASE, 3, 0x00);
					DEMO_PRINTF("ChangeKaraokeMode\r\n");
					break;
				}

                if(bLastSwitch){
                    bLastSongPressed = TRUE;
                    bNextSongPressed = FALSE;
                }
                 if(bNextSwitch){
                    bLastSongPressed = FALSE;
                    bNextSongPressed = TRUE;
                }
                if (bSdacrdReady && (bEndOfFile || bLastSongPressed || bNextSongPressed)){
                    bool bNextSong = FALSE;
                    bool bLastSong = FALSE;

                    if(bLastSongPressed) bLastSong = TRUE;
                    if(bNextSongPressed || bEndOfFile) bNextSong = TRUE;
                    // check whether in REPEAT mode
                    if (!bLastSongPressed && !bNextSongPressed && gWavePlay.bRepeatMode){
                        bNextSong = FALSE;  // in repeat mode
                        bLastSong = FALSE;
                    }
                    if (bNextSong){  // index update for next song
                        nPlayIndex++;
                        if (nPlayIndex >= gWavePlayList.nFileNum)
                            nPlayIndex = 0;
                    }
                    if (bLastSong){  // index update for last song
                        nPlayIndex--;
                        if (nPlayIndex < 0)
                            nPlayIndex = gWavePlayList.nFileNum-1;
                    }
                    bPlayDone = TRUE;
                    DEMO_PRINTF("PlayDone\n");
                    /*
                    DEMO_PRINTF("bSdacrdReady:%d\n",bSdacrdReady);
                    DEMO_PRINTF("bEndOfFile:%d\n",bEndOfFile);
                    DEMO_PRINTF("bLastSongPressed:%d\n",bLastSongPressed);
                    DEMO_PRINTF("bNextSongPressed:%d\n",bNextSongPressed);
                    */

                }
                bLastSwitch = FALSE;
                bNextSwitch = FALSE;

                uTimeElapsed = alt_nticks() - uSongStartTime;
                DisplayTime(uTimeElapsed);
            }
            /*
            DEMO_PRINTF("End while loop\n");
            DEMO_PRINTF("bPlayDone:%d\n",bPlayDone);
            DEMO_PRINTF("bSdacrdReady:%d\n",bSdacrdReady);
            */
            // while(!bPlayNextSong && bSdacrdReady)
            waveplay_stop();
        }  // while(bSdacrdReady)
  } // while (1)

  return 0;
}
