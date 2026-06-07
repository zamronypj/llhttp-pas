# llhttp header translation for Free Pascal

## What is this
This is [Free Pascal](https://www.freepascal.org) header translation for [llhttp](https://llhttp.org) library.

## Building llhttp

Clone [llhtp git repository](https://github.com/nodejs/llhttp).
Make sure you have Clang, Node.js and NPM installed in your system. These are requirements for building llhttp, not llhttp-pas.

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

function on_message_begin(parser: pllhttp_t): integer; cdecl;
begin
    writeln('parse start');
    result := 0;
end;

function on_url(parser: pllhttp_t; const at: pansichar; length: size_t): integer; cdecl;
var url: string;
begin
    url := copy(at, length);
    writeln('on_url: ', url);
    result:= 0;
end;


function on_header_field(parser: pllhttp_t; const at:pansichar; length: size_t): integer; cdecl;
var header_field: string;
begin
    header_field := copy(at, length);
    writeln('head field: ', header_field);
    result := 0;
end;

function on_header_value(parser: pllhttp_t; const at:pansichar; length: size_t): integer; cdecl;
var header_value: string;
begin
    header_value := copy(at, length);
    writeln('head value: ', header_value);
    result := 0;
end;

function on_headers_complete(parser: pllhttp_t): integer; cdecl;
begin
    writeln('on_headers_complete, major: ', parser^.http_major,
      ' minor: ', parser^.http_minor,
      'keep-alive: ', llhttp_should_keep_alive(parser),
      'upgrade: ', parser^.upgrade);
    result := 0;
end;

function on_body(parser: pllhttp_t; const at: PAnsichar; length: size_t): integer; cdecl;
var body: string;
begin
    body := copy(at, length);
    writeln('on body: ', body);
    result := 0;
end;

function handle_on_message_complete(parser : pllhttp_t) : integer; cdecl;
begin
    writeln('ok');
    result := 0;
end;

begin
    (* Initialize user callbacks and settings *)
    llhttp_settings_init(@settings);

    (* Set user callback *)
    settings.on_message_begin := @on_message_begin;
    settings.on_url := @on_url;
    settings.on_header_field := @on_header_field;
    settings.on_header_value := @on_header_value;
    settings.on_headers_complete := @on_headers_complete;
    settings.on_body := @on_body;
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
