/*
 * wine-wolf-bridge preload v1 — observability + governed FS open path hook.
 * LD_PRELOAD alone is NOT a security boundary; seccomp governs on Linux.
 */
#define _GNU_SOURCE
#include <dlfcn.h>
#include <errno.h>
#include <fcntl.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <sys/un.h>
#include <unistd.h>

static int bridge_request(const char *verb, const char *path_json) {
  const char *sock_path = getenv("COGOS_UL_BRIDGE_SOCK");
  if (!sock_path || !sock_path[0]) return -1;
  int fd = socket(AF_UNIX, SOCK_STREAM, 0);
  if (fd < 0) return -1;
  struct sockaddr_un addr;
  memset(&addr, 0, sizeof(addr));
  addr.sun_family = AF_UNIX;
  strncpy(addr.sun_path, sock_path, sizeof(addr.sun_path) - 1);
  if (connect(fd, (struct sockaddr *)&addr, sizeof(addr)) < 0) {
    close(fd);
    return -1;
  }
  char line[4096];
  snprintf(line, sizeof(line),
           "{\"verb\":\"%s\",\"args\":%s,\"caller_pid\":%d}\n",
           verb, path_json, (int)getpid());
  send(fd, line, strlen(line), 0);
  char resp[512];
  ssize_t n = recv(fd, resp, sizeof(resp) - 1, 0);
  close(fd);
  if (n <= 0) return -1;
  resp[n] = '\0';
  if (strstr(resp, "\"ok\": false") || strstr(resp, "\"ok\":false")) return EACCES;
  return 0;
}

static int path_to_json(const char *path, char *out, size_t outlen) {
  snprintf(out, outlen, "{\"path\":\"%s\"}", path ? path : "");
  return 0;
}

int open(const char *pathname, int flags, ...) {
  typedef int (*open_fn)(const char *, int, ...);
  open_fn real_open = (open_fn)dlsym(RTLD_NEXT, "open");
  mode_t mode = 0;
  if (flags & O_CREAT) {
    va_list ap;
    va_start(ap, flags);
    mode = (mode_t)va_arg(ap, int);
    va_end(ap);
  }
  char jpath[2048];
  path_to_json(pathname, jpath, sizeof(jpath));
  if (bridge_request("ul.fs.read", jpath) == EACCES) {
    errno = EACCES;
    return -1;
  }
  if (flags & O_CREAT) return real_open(pathname, flags, mode);
  return real_open(pathname, flags);
}
