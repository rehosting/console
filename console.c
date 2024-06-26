#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <signal.h>

// Bind a shell to a serial console and ensure
// the session has support for job control (e.g.,
// ctrl+c, ctrl+z)

// Explicitly re-raise the signal to the default handler

void handle_sigint(int sig) {
    signal(sig, SIG_DFL);
    raise(sig);
}

void handle_sigtstp(int sig) {
    signal(sig, SIG_DFL);
    raise(sig);
}

int main(int argc, char **argv) {
    int fd;

    // fork to ensure we are not a session leader
    pid_t pid = fork();
    if (pid < 0) {
        perror("fork failed");
        return 1;
    } else if (pid > 0) {
        // i.e. parent process
        exit(0);
    }

    if (setsid() == -1) {
        perror("setsid failed");
        return 1;
    }

    close(2);
    close(1);
    close(0);

    if ((fd = open(SERIAL, O_RDWR, 0) == -1)) {
        perror("cons: Could not open \"" SERIAL "\": ");
        return -1;
    }

    dup2(fd, 0);
    dup2(fd, 1);
    dup2(fd, 2);

    putenv("TERM=linux");
    putenv("PATH=/sbin:/bin:/usr/sbin:/usr/bin");

    // Set up signal handlers for SIGINT and SIGTSTP
    signal(SIGINT, handle_sigint);
    signal(SIGTSTP, handle_sigtstp);

    return execl(SHELL, SHELL, NULL);
}
