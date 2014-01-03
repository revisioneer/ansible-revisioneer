# ansible-revisioneer

Notification role for revisioneer

## Prerequires:

- git must be installed

## Usage

Assuming you have a bare git clone of your applications repository:

    -
      role: nicolai86.ansible-revisioneer

      path: /path/to/repo
      revisioneer_token: my-secret-token