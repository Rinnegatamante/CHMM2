#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <malloc.h>
#include <unistd.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>
#include <arpa/inet.h>
#include <fcntl.h>

#define u32 uint32_t

typedef struct
{
	u32 sock;
	struct sockaddr_in addrTo;
} Socket;

int main(int argc,char** argv){

	// Getting IP
	char* host = (char*)(argv[1]);
	
	// Writing info on the screen
	printf("CHMM2 Theme Sender\n");
	printf("Client IP: ");
	printf(host);
	
	// Creating client socket
	Socket* my_socket = (Socket*) malloc(sizeof(Socket));
	my_socket->addrTo.sin_family = AF_INET;
	my_socket->addrTo.sin_port = htons(5000);
	my_socket->addrTo.sin_addr.s_addr = inet_addr(host);
	my_socket->sock = socket(AF_INET, SOCK_STREAM, 0);
	my_socket->sock = socket(AF_INET, SOCK_STREAM, 0);
	if (my_socket->sock < 0){
		printf("\nFailed creating socket.");	
		return -1;
	}else printf("\nClient socket created on port 5000");
	fcntl(my_socket->sock, F_SETFL, O_NONBLOCK);
	
	// Connecting to CHMM2
	int err = connect(my_socket->sock, (struct sockaddr*)&my_socket->addrTo, sizeof(my_socket->addrTo));
	if (err < 0 ){ 
		printf("\nFailed connecting server.");
		close(my_socket->sock);
		return -1;
	}else printf("\nConnection estabilished, waiting for CHMM2 response...");
	
	// Waiting for magic
	char data[11];
	int count = recv(my_socket->sock, &data, 11, 0);
	while (count < 0){
		int count = recv(my_socket->sock, &data, 11, 0);
	}
	if (strcmp(data,"YATA SENDER") == 0) printf("\nMagic received, starting transfer...");
	else{
		printf("Wrong magic received, connection aborted.");
		close(my_socket->sock);
		return -1;
	}
	
	// Transfering ZIP file
	printf("\nOpening file.zip ...");
	FILE* input = fopen("./file.zip","r");
	if (input < 0){
		printf("\nFile not found.");
		close(my_socket->sock);
		return -1;
	}
	int size = fseek(input, 0, SEEK_END);
	fseek(input, 0, SEEK_SET);
	char* buffer = (char*)malloc(size);
	fread(buffer, size, 1, input);
	fclose(input);
	printf("\nSending file...");
	send(my_socket->sock, buffer, size, 0);
	printf("\nFile successfully sent!");
	close(my_socket->sock);
	free(buffer);
	return 1;
	
}