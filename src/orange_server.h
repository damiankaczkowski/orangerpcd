/*
	JUCI Backend Websocket API Server

	Copyright (C) 2016 Martin K. Schröder <mkschreder.uk@gmail.com>

	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version. (Please read LICENSE file on special
	permission to include this software in signed images). 

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.
*/

#pragma once

#include <inttypes.h>
#include "orange_message.h"

#define UBUS_PEER_BROADCAST (-1)

struct orange_server_api; 
typedef const struct orange_server_api** orange_server_t; 

struct orange_server_api {
	void 	(*destroy)(orange_server_t ptr); 
	int 	(*listen)(orange_server_t ptr, const char *path); 
	int 	(*connect)(orange_server_t ptr, const char *path);
	int 	(*send)(orange_server_t ptr, struct orange_message **msg); 
	int 	(*recv)(orange_server_t ptr, struct orange_message **msg, unsigned long long timeout_us); 
	void*	(*userdata)(orange_server_t ptr, void *data); 
}; 

#define UBUS_TARGET_PEER (0)
#define UBUS_BROADCAST_PEER (-1)

#define orange_server_delete(sock) {(*sock)->destroy(sock); sock = NULL;} 
#define orange_server_listen(sock, path) (*sock)->listen(sock, path)
#define orange_server_connect(sock, path) (*sock)->connect(sock, path) 
#define orange_server_send(sock, msg) (*sock)->send(sock, msg)
#define orange_server_recv(sock, msg, timeout) (*sock)->recv(sock, msg, timeout)
#define orange_server_get_userdata(sock) (*sock)->userdata(sock, NULL)
#define orange_server_set_userdata(sock, ptr) (*sock)->userdata(sock, ptr)
