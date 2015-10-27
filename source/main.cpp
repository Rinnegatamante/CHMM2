/*----------------------------------------------------------------------------------------------------------------------#
#-----------------------------------------------------------------------------------------------------------------------#
#------  This File is Part Of : ----------------------------------------------------------------------------------------#
#------- _  -------------------  ______   _   --------------------------------------------------------------------------#
#------ | | ------------------- (_____ \ | |  --------------------------------------------------------------------------#
#------ | | ---  _   _   ____    _____) )| |  ____  _   _   ____   ____   ----------------------------------------------#
#------ | | --- | | | | / _  |  |  ____/ | | / _  || | | | / _  ) / ___)  ----------------------------------------------#
#------ | |_____| |_| |( ( | |  | |      | |( ( | || |_| |( (/ / | |  --------------------------------------------------#
#------ |_______)\____| \_||_|  |_|      |_| \_||_| \__  | \____)|_|  --------------------------------------------------#
#------------------------------------------------- (____/  -------------------------------------------------------------#
#------------------------   ______   _   -------------------------------------------------------------------------------#
#------------------------  (_____ \ | |  -------------------------------------------------------------------------------#
#------------------------   _____) )| | _   _   ___   ------------------------------------------------------------------#
#------------------------  |  ____/ | || | | | /___)  ------------------------------------------------------------------#
#------------------------  | |      | || |_| ||___ |  ------------------------------------------------------------------#
#------------------------  |_|      |_| \____|(___/   ------------------------------------------------------------------#
#-----------------------------------------------------------------------------------------------------------------------#
#-----------------------------------------------------------------------------------------------------------------------#
#- Licensed under the GPL License --------------------------------------------------------------------------------------#
#-----------------------------------------------------------------------------------------------------------------------#
#- Copyright (c) Nanni <lpp.nanni@gmail.com> ---------------------------------------------------------------------------#
#- Copyright (c) Rinnegatamante <rinnegatamante@gmail.com> -------------------------------------------------------------#
#-----------------------------------------------------------------------------------------------------------------------#
#-----------------------------------------------------------------------------------------------------------------------#
#- Credits : -----------------------------------------------------------------------------------------------------------#
#-----------------------------------------------------------------------------------------------------------------------#
#- Smealum for ctrulib and ftpony src ----------------------------------------------------------------------------------#
#- StapleButter for debug font -----------------------------------------------------------------------------------------#
#- Lode Vandevenne for lodepng -----------------------------------------------------------------------------------------#
#- Jean-loup Gailly and Mark Adler for zlib ----------------------------------------------------------------------------#
#- Special thanks to Aurelio for testing, bug-fixing and various help with codes and implementations -------------------#
#-----------------------------------------------------------------------------------------------------------------------*/

#include <stdio.h>
#include <string.h>
#include <3ds.h>
#include "include/luaplayer.h"
#include "include/Graphics/Graphics.h"
#include "include/ftp/ftp.h"
#include "include/khax/khax.h"
#include "index.cpp"

const char *errMsg;
unsigned char *buffer;
char cur_dir[256];
char start_dir[256];
bool CIA_MODE;
bool is3DSX;
bool isNinjhax2;

int main(int argc, char **argv)
{
	srvInit();	
	aptInit();
	gfxInitDefault();
	acInit();
	initCfgu();
	httpcInit();
	ptmInit();
	hidInit();
	irrstInit();
	aptOpenSession();
	Result ret=APT_SetAppCpuTimeLimit(NULL, 30);
	aptCloseSession();
	fsInit();
	Handle fileHandle;
	u64 size;
	u32 bytesRead;
	int restore;
	
	if (argc > 0) is3DSX = true;
	else is3DSX = false;
	
	// Check user build and enables kernel access
	if (nsInit()==0){
		CIA_MODE = true;
		nsExit();
	}else CIA_MODE = false;
	isNinjhax2 = false;
	if (!hbInit()) khaxInit();
	else isNinjhax2 = true;
	
	
	while(aptMainLoop())
	{
		restore=0;		
		char error[2048];
		
		restore=0;		
		char startstring[256];
		if (!is3DSX){
			while (aptGetStatus() != 0x04 or aptGetStatusPower() != 0x01){
				sprintf(startstring,"CHMM Controls:\n\nA = Install Theme\nY = Theme Preview\nSTART = Exit CHMM\n\nPress POWER to initialize CHMM.");
				RefreshScreen();
				ClearScreen(0);
				ClearScreen(1);
				DebugOutput(startstring);
				gfxFlushBuffers();
				gfxSwapBuffers();
				gspWaitForVBlank();
			}
		}
		
		errMsg = runScript((char*)index_lua, true);
		
		if (errMsg != NULL);{
		
			// Fake error to force interpreter shutdown
			if (strstr(errMsg, "lpp_exit_04")) break;
			
		}
		bool ftp_state = false;
		int connfd;
		while (restore==0){
			gspWaitForVBlank();
			RefreshScreen();
			ClearScreen(0);
			ClearScreen(1);
			strcpy(error,"Error: ");
			strcat(error,errMsg);
			if (ftp_state){ 
				u32 ip=(u32)gethostid();
				char ip_address[64];
				strcat(error,"\n\nPress A to restart\nPress B to exit\nPress Y to enable FTP server\n\nFTP state: ON\nIP: ");
				sprintf(ip_address,"%lu.%lu.%lu.%lu", ip & 0xFF, (ip>>8)&0xFF, (ip>>16)&0xFF, (ip>>24)&0xFF);
				strcat(error,ip_address);
				strcat(error,"\nPort: 5000");
				if(connfd<0)connfd=ftp_getConnection();
				else{
					int ret=ftp_frame(connfd);
					if(ret==1) connfd=-1;
				}
			}else strcat(error,"\n\nPress A to restart\nPress B to exit\nPress Y to enable FTP server\n\nFTP state: OFF");
			DebugOutput(error);
			hidScanInput();
			if(hidKeysDown() & KEY_A){
				strcpy(cur_dir,start_dir);
				restore=1;
			}else if(hidKeysDown() & KEY_B){
				restore=2;
			}else if(hidKeysDown() & KEY_Y){
				if (!ftp_state){
					u32 wifiStatus;
					if ((u32)ACU_GetWifiStatus(NULL, &wifiStatus) !=  0xE0A09D2E){
						if (wifiStatus != 0){
							ftp_init();
							connfd = -1;
							ftp_state = true;
						}
					}
				}
			}
			
			gfxFlushBuffers();
			gfxSwapBuffers();
		}
		if (ftp_state) ftp_exit();
		if (isCSND){
			CSND_shutdown();
			isCSND = false;
		}
		if (restore==2){
			break;
		}
	}
	if (!CIA_MODE) khaxExit();
	fsExit();
	irrstExit();
	hidExit();
	ptmExit();
	hbExit();
	acExit();
	httpcExit();
	exitCfgu();
	gfxExit();
	aptExit();
	srvExit();

	return 0;
}
