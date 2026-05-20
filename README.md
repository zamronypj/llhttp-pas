# llhttp header translation for Free Pascal

## What is this
This is [Free Pascal](https://www.freepascal.org) header translation for [llhttp](https://llhttp.org) library.

It is currently work in progress and not fully tested.

## Building llhttp


Clone [llhtp git repository](https://github.com/nodejs/llhttp).
Make sure you have Clang, Node.js and NPM installed in your system.
Change directory to llhttp source directory.

Run

```
$ npm ci && make
```

If build is successful, `libllhttp.a` and `libllhttp.so` are created  in `build` directory inside llhttp source dir. This unit translation links static library so does not use `libllhttp.so`.

## Usage

Copy `libllhttp.a` and `llhttp.pas` to your project.

```
{$MODE OBJFPC}
{$H+}

uses
    llhttp;

var
    parser : llhttp_t;
    settings : llhttp_settings_t;
    request : string;
    err : llhttp_errno_t;

function handle_on_message_complete(parser : pllhttp_t) : integer; cdecl;
begin
    writeln('ok');
    result := 0;
end;

begin
    (* Initialize user callbacks and settings *)
    llhttp_settings_init(@settings);

    (* Set user callback *)
    settings.on_message_complete := @handle_on_message_complete;

    (* Initialize the parser in HTTP_BOTH mode, meaning that it will select between
     * HTTP_REQUEST and HTTP_RESPONSE parsing automatically while reading the first
     * input.
     *)
    llhttp_init(@parser, HTTP_BOTH, @settings);

    (* Parse request! *)
    request := 'GET / HTTP/1.1' + #13#10 + #13#10;

    err := llhttp_execute(@parser, pansichar(request), length(request));
    if (err = HPE_OK) then
    begin
        (* Successfully parsed! *)
    end else
    begin
        writeln(stderr, 'Parse error: ', llhttp_errno_name(err), parser.reason);
    end;
end.
```
