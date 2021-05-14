# llhttp header translation for Free Pascal

## What is this
This is [Free Pascal](https://www.freepascal.org) header translation for [llhttp](https://llhttp.org) library.

It is currently work in progress and not fully tested.

## Usage

```
{$MODE OBJFPC}
{$H+}

uses
    libllhttp;

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

##