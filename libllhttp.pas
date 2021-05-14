{*!
 * llhttp header translation for Free Pascal
 *
 * @link      https://github.com/zamronypj/llhttp-pas
 * @copyright Copyright (c) 2021 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/llhttp-pas/blob/master/LICENSE (MIT)
 *}

unit libllhttp;

interface

{$MODE OBJFPC}
{$PACKRECORDS C}

const

    {$IFDEF WINDOWS}
        LIBLLHTTP_FILE = 'libllhttp.dll';
    {$ELSE}
        {$IFDEF UNIX}
        LIBLLHTTP_FILE = 'libllhttp.so';
        {$ENDIF}
    {$ENDIF}

    LLHTTP_VERSION_MAJOR = 6;
    LLHTTP_VERSION_MINOR = 0;
    LLHTTP_VERSION_PATCH = 1;

type

    llhttp_errno_t = (
        HPE_OK = 0,
        HPE_INTERNAL = 1,
        HPE_STRICT = 2,
        HPE_LF_EXPECTED = 3,
        HPE_UNEXPECTED_CONTENT_LENGTH = 4,
        HPE_CLOSED_CONNECTION = 5,
        HPE_INVALID_METHOD = 6,
        HPE_INVALID_URL = 7,
        HPE_INVALID_CONSTANT = 8,
        HPE_INVALID_VERSION = 9,
        HPE_INVALID_HEADER_TOKEN = 10,
        HPE_INVALID_CONTENT_LENGTH = 11,
        HPE_INVALID_CHUNK_SIZE = 12,
        HPE_INVALID_STATUS = 13,
        HPE_INVALID_EOF_STATE = 14,
        HPE_INVALID_TRANSFER_ENCODING = 15,
        HPE_CB_MESSAGE_BEGIN = 16,
        HPE_CB_HEADERS_COMPLETE = 17,
        HPE_CB_MESSAGE_COMPLETE = 18,
        HPE_CB_CHUNK_HEADER = 19,
        HPE_CB_CHUNK_COMPLETE = 20,
        HPE_PAUSED = 21,
        HPE_PAUSED_UPGRADE = 22,
        HPE_PAUSED_H2_UPGRADE = 23,
        HPE_USER = 24
    );

    llhttp_flags_t = (
        F_CONNECTION_KEEP_ALIVE = $1,
        F_CONNECTION_CLOSE = $2,
        F_CONNECTION_UPGRADE = $4,
        F_CHUNKED = $8,
        F_UPGRADE = $10,
        F_CONTENT_LENGTH = $20,
        F_SKIPBODY = $40,
        F_TRAILING = $80,
        F_TRANSFER_ENCODING = $200
    );

    llhttp_lenient_flags_t = (
        LENIENT_HEADERS = $1,
        LENIENT_CHUNKED_LENGTH = $2,
        LENIENT_KEEP_ALIVE = $4
    );

    llhttp_type_t = (
        HTTP_BOTH = 0,
        HTTP_REQUEST = 1,
        HTTP_RESPONSE = 2
    );

    llhttp_finish_t = (
        HTTP_FINISH_SAFE = 0,
        HTTP_FINISH_SAFE_WITH_CB = 1,
        HTTP_FINISH_UNSAFE = 2
    );

    llhttp_method_t = (
        HTTP_DELETE = 0,
        HTTP_GET = 1,
        HTTP_HEAD = 2,
        HTTP_POST = 3,
        HTTP_PUT = 4,
        HTTP_CONNECT = 5,
        HTTP_OPTIONS = 6,
        HTTP_TRACE = 7,
        HTTP_COPY = 8,
        HTTP_LOCK = 9,
        HTTP_MKCOL = 10,
        HTTP_MOVE = 11,
        HTTP_PROPFIND = 12,
        HTTP_PROPPATCH = 13,
        HTTP_SEARCH = 14,
        HTTP_UNLOCK = 15,
        HTTP_BIND = 16,
        HTTP_REBIND = 17,
        HTTP_UNBIND = 18,
        HTTP_ACL = 19,
        HTTP_REPORT = 20,
        HTTP_MKACTIVITY = 21,
        HTTP_CHECKOUT = 22,
        HTTP_MERGE = 23,
        HTTP_MSEARCH = 24,
        HTTP_NOTIFY = 25,
        HTTP_SUBSCRIBE = 26,
        HTTP_UNSUBSCRIBE = 27,
        HTTP_PATCH = 28,
        HTTP_PURGE = 29,
        HTTP_MKCALENDAR = 30,
        HTTP_LINK = 31,
        HTTP_UNLINK = 32,
        HTTP_SOURCE = 33,
        HTTP_PRI = 34,
        HTTP_DESCRIBE = 35,
        HTTP_ANNOUNCE = 36,
        HTTP_SETUP = 37,
        HTTP_PLAY = 38,
        HTTP_PAUSE = 39,
        HTTP_TEARDOWN = 40,
        HTTP_GET_PARAMETER = 41,
        HTTP_SET_PARAMETER = 42,
        HTTP_REDIRECT = 43,
        HTTP_RECORD = 44,
        HTTP_FLUSH = 45
    );

    llhttp__internal_t = record
        _index : int32;
        _span_pos0 : pointer;
        _span_cb0 : pointer;
        error : int32;
        reason : pansichar;
        error_pos : pansichar;
        data : pointer;
        _current : pointer;
        content_length : uint64 ;
        &type : uint8;
        method : uint8;
        http_major : uint8;
        http_minor : uint8;
        header_state : uint8;
        lenient_flags : uint8;
        upgrade : uint8;
        finish : uint8;
        flags : uint16;
        status_code : uint16;
        settings : pointer;
    end;
    llhttp_t = llhttp__internal_t;
    pllhttp_t = ^llhttp_t;

    llhttp_data_cb = function(
        parser : pllhttp_t;
        at : pansichar;
        length : size_t
    ) : integer; cdecl;

    llhttp_cb = function(parser : pllhttp_t) : integer; cdecl;

    llhttp_settings_t = record
        (* Possible return values 0, -1, `HPE_PAUSED` *)
        on_message_begin : llhttp_cb;

        (* Possible return values 0, -1, HPE_USER *)
        on_url : llhttp_data_cb;
        on_status : llhttp_data_cb;
        on_header_field : llhttp_data_cb;
        on_header_value : llhttp_data_cb;

        (* Possible return values:
         * 0  - Proceed normally
         * 1  - Assume that request/response has no body, and proceed to parsing the
         *      next message
         * 2  - Assume absence of body (as above) and make `llhttp_execute()` return
         *      `HPE_PAUSED_UPGRADE`
         * -1 - Error
         * `HPE_PAUSED`
         *)
        on_headers_complete : llhttp_cb;

        (* Possible return values 0, -1, HPE_USER *)
         on_body : llhttp_data_cb;

        (* Possible return values 0, -1, `HPE_PAUSED` *)
        on_message_complete : llhttp_cb;

        (* When on_chunk_header is called, the current chunk length is stored
         * in parser->content_length.
         * Possible return values 0, -1, `HPE_PAUSED`
         *)
        on_chunk_header : llhttp_cb;
        on_chunk_complete : llhttp_cb;

        (* Information-only callbacks, return value is ignored *)
        on_url_complete : llhttp_cb;
        on_status_complete : llhttp_cb;
        on_header_field_complete : llhttp_cb;
        on_header_value_complete : llhttp_cb;
    end;
    pllhttp_settings_t = ^llhttp_settings_t;

(* Initialize the parser with specific type and user settings.
 *
 * NOTE: lifetime of `settings` has to be at least the same as the lifetime of
 * the `parser` here. In practice, `settings` has to be either a static
 * variable or be allocated with `malloc`, `new`, etc.
 *)
procedure llhttp_init(
    parser : pllhttp_t;
    type_t : llhttp_type_t;
    settings : pllhttp_settings_t
); cdecl;

{$IFDEF __wasm__}

function llhttp_alloc(type_t : llhttp_type_t) : plhttp_t; cdecl;

procedure llhttp_free(parser : pllhttp_t); cdecl;

function llhttp_get_type(parser : pllhttp_t) : uint8; cdecl;

function llhttp_get_http_major(parser : pllhttp_t) : uint8; cdecl;

function llhttp_get_http_minor(parser : pllhttp_t) : uint8; cdecl;

function llhttp_get_method(parser : pllhttp_t) : uint8; cdecl;

function llhttp_get_status_code(parser : pllhttp_t) : integer; cdecl;

function llhttp_get_upgrade(parser : pllhttp_t) : uint8; cdecl;

{$ENDIF}

(* Reset an already initialized parser back to the start state, preserving the
 * existing parser type, callback settings, user data, and lenient flags.
 *)
procedure llhttp_reset(parser : pllhttp_t); cdecl;

(* Initialize the settings object *)
procedure llhttp_settings_init(settings : pllhttp_settings_t); cdecl;

(* Parse full or partial request/response, invoking user callbacks along the
 * way.
 *
 * If any of `llhttp_data_cb` returns errno not equal to `HPE_OK` - the parsing
 * interrupts, and such errno is returned from `llhttp_execute()`. If
 * `HPE_PAUSED` was used as a errno, the execution can be resumed with
 * `llhttp_resume()` call.
 *
 * In a special case of CONNECT/Upgrade request/response `HPE_PAUSED_UPGRADE`
 * is returned after fully parsing the request/response. If the user wishes to
 * continue parsing, they need to invoke `llhttp_resume_after_upgrade()`.
 *
 * NOTE: if this function ever returns a non-pause type error, it will continue
 * to return the same error upon each successive call up until `llhttp_init()`
 * is called.
 *)
function llhttp_execute(
    parser : pllhttp_t;
    data : pansichar;
    len : size_t
) : llhttp_errno_t; cdecl;

(* This method should be called when the other side has no further bytes to
 * send (e.g. shutdown of readable side of the TCP connection.)
 *
 * Requests without `Content-Length` and other messages might require treating
 * all incoming bytes as the part of the body, up to the last byte of the
 * connection. This method will invoke `on_message_complete()` callback if the
 * request was terminated safely. Otherwise a error code would be returned.
 *)
function llhttp_finish(parser : llhttp_t) : llhttp_errno_t; cdecl;

(* Returns `1` if the incoming message is parsed until the last byte, and has
 * to be completed by calling `llhttp_finish()` on EOF
 *)
function llhttp_message_needs_eof(parser : pllhttp_t) : integer; cdecl;

(* Returns `1` if there might be any other messages following the last that was
 * successfully parsed.
 *)
function llhttp_should_keep_alive(parser : pllhttp_t) : integer; cdecl;

(* Make further calls of `llhttp_execute()` return `HPE_PAUSED` and set
 * appropriate error reason.
 *
 * Important: do not call this from user callbacks! User callbacks must return
 * `HPE_PAUSED` if pausing is required.
 *)
procedure llhttp_pause(parser : pllhttp_t); cdecl;

(* Might be called to resume the execution after the pause in user's callback.
 * See `llhttp_execute()` above for details.
 *
 * Call this only if `llhttp_execute()` returns `HPE_PAUSED`.
 *)
procedure llhttp_resume(parser : pllhttp_t); cdecl;

(* Might be called to resume the execution after the pause in user's callback.
 * See `llhttp_execute()` above for details.
 *
 * Call this only if `llhttp_execute()` returns `HPE_PAUSED_UPGRADE`
 *)
procedure llhttp_resume_after_upgrade(parser : pllhttp_t); cdecl;

(* Returns the latest return error *)
function llhttp_get_errno(parser : pllhttp_t) : llhttp_errno_t; cdecl;

(* Returns the verbal explanation of the latest returned error.
 *
 * Note: User callback should set error reason when returning the error. See
 * `llhttp_set_error_reason()` for details.
 *)
function llhttp_get_error_reason(parser : pllhttp_t) : pansichar; cdecl;

(* Assign verbal description to the returned error. Must be called in user
 * callbacks right before returning the errno.
 *
 * Note: `HPE_USER` error code might be useful in user callbacks.
 *)
procedure llhttp_set_error_reason(parser : pllhttp_t; reason : pansichar); cdecl;

(* Returns the pointer to the last parsed byte before the returned error. The
 * pointer is relative to the `data` argument of `llhttp_execute()`.
 *
 * Note: this method might be useful for counting the number of parsed bytes.
 *)
function llhttp_get_error_pos(parser : pllhttp_t) : pansichar; cdecl;

(* Returns textual name of error code *)
function llhttp_errno_name(err : llhttp_errno_t) : pansichar; cdecl;

(* Returns textual name of HTTP method *)
function llhttp_method_name(method : llhttp_method_t) : pansichar; cdecl;


(* Enables/disables lenient header value parsing (disabled by default).
 *
 * Lenient parsing disables header value token checks, extending llhttp's
 * protocol support to highly non-compliant clients/server. No
 * `HPE_INVALID_HEADER_TOKEN` will be raised for incorrect header values when
 * lenient parsing is "on".
 *
 * **(USE AT YOUR OWN RISK)**
 *)
procedure llhttp_set_lenient_headers(parser : pllhttp_t; enabled : integer); cdecl;


(* Enables/disables lenient handling of conflicting `Transfer-Encoding` and
 * `Content-Length` headers (disabled by default).
 *
 * Normally `llhttp` would error when `Transfer-Encoding` is present in
 * conjunction with `Content-Length`. This error is important to prevent HTTP
 * request smuggling, but may be less desirable for small number of cases
 * involving legacy servers.
 *
 * **(USE AT YOUR OWN RISK)**
 *)
procedure llhttp_set_lenient_chunked_length(parser : pllhttp_t; enabled : integer); cdecl;


(* Enables/disables lenient handling of `Connection: close` and HTTP/1.0
 * requests responses.
 *
 * Normally `llhttp` would error on (in strict mode) or discard (in loose mode)
 * the HTTP request/response after the request/response with `Connection: close`
 * and `Content-Length`. This is important to prevent cache poisoning attacks,
 * but might interact badly with outdated and insecure clients. With this flag
 * the extra request/response will be parsed normally.
 *
 * **(USE AT YOUR OWN RISK)**
 *)
procedure llhttp_set_lenient_keep_alive(parser: pllhttp_t; enabled : integer); cdecl;

implementation

(* Initialize the parser with specific type and user settings.
 *
 * NOTE: lifetime of `settings` has to be at least the same as the lifetime of
 * the `parser` here. In practice, `settings` has to be either a static
 * variable or be allocated with `malloc`, `new`, etc.
 *)
procedure llhttp_init(
    parser : pllhttp_t;
    type_t : llhttp_type_t;
    settings : pllhttp_settings_t
); cdecl; external LIBLLHTTP_FILE;

{$IFDEF __wasm__}

function llhttp_alloc(type_t : llhttp_type_t) : plhttp_t; cdecl; external LIBLLHTTP_FILE;

procedure llhttp_free(parser : pllhttp_t); cdecl; external LIBLLHTTP_FILE;

function llhttp_get_type(parser : pllhttp_t) : uint8; cdecl; external LIBLLHTTP_FILE;

function llhttp_get_http_major(parser : pllhttp_t) : uint8; cdecl; external LIBLLHTTP_FILE;

function llhttp_get_http_minor(parser : pllhttp_t) : uint8; cdecl; external LIBLLHTTP_FILE;

function llhttp_get_method(parser : pllhttp_t) : uint8; cdecl; external LIBLLHTTP_FILE;

function llhttp_get_status_code(parser : pllhttp_t) : integer; cdecl; external LIBLLHTTP_FILE;

function llhttp_get_upgrade(parser : pllhttp_t) : uint8; cdecl; external LIBLLHTTP_FILE;

{$ENDIF}

(* Reset an already initialized parser back to the start state, preserving the
 * existing parser type, callback settings, user data, and lenient flags.
 *)
procedure llhttp_reset(parser : pllhttp_t); cdecl; external LIBLLHTTP_FILE;

(* Initialize the settings object *)
procedure llhttp_settings_init(settings : pllhttp_settings_t); cdecl; external LIBLLHTTP_FILE;

(* Parse full or partial request/response, invoking user callbacks along the
 * way.
 *
 * If any of `llhttp_data_cb` returns errno not equal to `HPE_OK` - the parsing
 * interrupts, and such errno is returned from `llhttp_execute()`. If
 * `HPE_PAUSED` was used as a errno, the execution can be resumed with
 * `llhttp_resume()` call.
 *
 * In a special case of CONNECT/Upgrade request/response `HPE_PAUSED_UPGRADE`
 * is returned after fully parsing the request/response. If the user wishes to
 * continue parsing, they need to invoke `llhttp_resume_after_upgrade()`.
 *
 * NOTE: if this function ever returns a non-pause type error, it will continue
 * to return the same error upon each successive call up until `llhttp_init()`
 * is called.
 *)
function llhttp_execute(
    parser : pllhttp_t;
    data : pansichar;
    len : size_t
) : llhttp_errno_t; cdecl; external LIBLLHTTP_FILE;

(* This method should be called when the other side has no further bytes to
 * send (e.g. shutdown of readable side of the TCP connection.)
 *
 * Requests without `Content-Length` and other messages might require treating
 * all incoming bytes as the part of the body, up to the last byte of the
 * connection. This method will invoke `on_message_complete()` callback if the
 * request was terminated safely. Otherwise a error code would be returned.
 *)
function llhttp_finish(parser : llhttp_t) : llhttp_errno_t; cdecl; external LIBLLHTTP_FILE;

(* Returns `1` if the incoming message is parsed until the last byte, and has
 * to be completed by calling `llhttp_finish()` on EOF
 *)
function llhttp_message_needs_eof(parser : pllhttp_t) : integer; cdecl; external LIBLLHTTP_FILE;

(* Returns `1` if there might be any other messages following the last that was
 * successfully parsed.
 *)
function llhttp_should_keep_alive(parser : pllhttp_t) : integer; cdecl; external LIBLLHTTP_FILE;

(* Make further calls of `llhttp_execute()` return `HPE_PAUSED` and set
 * appropriate error reason.
 *
 * Important: do not call this from user callbacks! User callbacks must return
 * `HPE_PAUSED` if pausing is required.
 *)
procedure llhttp_pause(parser : pllhttp_t); cdecl; external LIBLLHTTP_FILE;

(* Might be called to resume the execution after the pause in user's callback.
 * See `llhttp_execute()` above for details.
 *
 * Call this only if `llhttp_execute()` returns `HPE_PAUSED`.
 *)
procedure llhttp_resume(parser : pllhttp_t); cdecl; external LIBLLHTTP_FILE;

(* Might be called to resume the execution after the pause in user's callback.
 * See `llhttp_execute()` above for details.
 *
 * Call this only if `llhttp_execute()` returns `HPE_PAUSED_UPGRADE`
 *)
procedure llhttp_resume_after_upgrade(parser : pllhttp_t); cdecl; external LIBLLHTTP_FILE;

(* Returns the latest return error *)
function llhttp_get_errno(parser : pllhttp_t) : llhttp_errno_t; cdecl; external LIBLLHTTP_FILE;

(* Returns the verbal explanation of the latest returned error.
 *
 * Note: User callback should set error reason when returning the error. See
 * `llhttp_set_error_reason()` for details.
 *)
function llhttp_get_error_reason(parser : pllhttp_t) : pansichar; cdecl; external LIBLLHTTP_FILE;

(* Assign verbal description to the returned error. Must be called in user
 * callbacks right before returning the errno.
 *
 * Note: `HPE_USER` error code might be useful in user callbacks.
 *)
procedure llhttp_set_error_reason(parser : pllhttp_t; reason : pansichar); cdecl; external LIBLLHTTP_FILE;

(* Returns the pointer to the last parsed byte before the returned error. The
 * pointer is relative to the `data` argument of `llhttp_execute()`.
 *
 * Note: this method might be useful for counting the number of parsed bytes.
 *)
function llhttp_get_error_pos(parser : pllhttp_t) : pansichar; cdecl; external LIBLLHTTP_FILE;

(* Returns textual name of error code *)
function llhttp_errno_name(err : llhttp_errno_t) : pansichar; cdecl; external LIBLLHTTP_FILE;

(* Returns textual name of HTTP method *)
function llhttp_method_name(method : llhttp_method_t) : pansichar; cdecl; external LIBLLHTTP_FILE;


(* Enables/disables lenient header value parsing (disabled by default).
 *
 * Lenient parsing disables header value token checks, extending llhttp's
 * protocol support to highly non-compliant clients/server. No
 * `HPE_INVALID_HEADER_TOKEN` will be raised for incorrect header values when
 * lenient parsing is "on".
 *
 * **(USE AT YOUR OWN RISK)**
 *)
procedure llhttp_set_lenient_headers(parser : pllhttp_t; enabled : integer); cdecl; external LIBLLHTTP_FILE;


(* Enables/disables lenient handling of conflicting `Transfer-Encoding` and
 * `Content-Length` headers (disabled by default).
 *
 * Normally `llhttp` would error when `Transfer-Encoding` is present in
 * conjunction with `Content-Length`. This error is important to prevent HTTP
 * request smuggling, but may be less desirable for small number of cases
 * involving legacy servers.
 *
 * **(USE AT YOUR OWN RISK)**
 *)
procedure llhttp_set_lenient_chunked_length(parser : pllhttp_t; enabled : integer); cdecl; external LIBLLHTTP_FILE;


(* Enables/disables lenient handling of `Connection: close` and HTTP/1.0
 * requests responses.
 *
 * Normally `llhttp` would error on (in strict mode) or discard (in loose mode)
 * the HTTP request/response after the request/response with `Connection: close`
 * and `Content-Length`. This is important to prevent cache poisoning attacks,
 * but might interact badly with outdated and insecure clients. With this flag
 * the extra request/response will be parsed normally.
 *
 * **(USE AT YOUR OWN RISK)**
 *)
procedure llhttp_set_lenient_keep_alive(parser: pllhttp_t; enabled : integer); cdecl; external LIBLLHTTP_FILE;

end.