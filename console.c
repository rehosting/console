#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>

// Bind a shell to a serial console and ensure
// the session has support for job control (e.g.,
// ctrl+c, ctrl+z)

int main(int argc, char **argv) {
    int fd;

    setsid();

    close(2);
    close(1);
    close(0);

    if ((fd = open(SERIAL, O_RDWR, 0) == -1)) {
        perror("cons: Could not open \"" SERIAL "\": ");
        return -1;
    }

    dup(fd);
    dup(fd);

    putenv("TERM=linux");
    putenv("PATH=/sbin:/bin:/usr/sbin:/usr/bin");

    return execl(SHELL, SHELL, NULL);
}
