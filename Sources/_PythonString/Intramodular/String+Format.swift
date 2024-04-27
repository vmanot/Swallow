//
// Copyright (c) Vatsal Manot
//

#if os(OSX)
import Darwin
#elseif os(Linux)
import Glibc
#endif
import Foundation


typealias Py_ssize_t = Int
typealias PyObject = Any
typealias int = Int
typealias long = Int
typealias size_t = Int
typealias double = Double
typealias Py_UCS4 = Character

let CHAR_MAX = 127

extension BinaryInteger {
    @discardableResult
    static prefix func ++(i: inout Self) -> Self {
        i += 1
        return i
    }
    @discardableResult
    static postfix func ++(i: inout Self) -> Self {
        let tmp = i
        i += 1
        return tmp
    }
    @discardableResult
    static prefix func --(i: inout Self) -> Self {
        i -= 1
        return i
    }
    @discardableResult
    static postfix func --(i: inout Self) -> Self {
        let tmp = i
        i -= 1
        return tmp
    }
}

/*
 unicode_format.h -- implementation of str.format().
 */

/************************************************************************/
/***********   Global data structures and forward declarations  *********/
/************************************************************************/


typealias FormatResult = Result<String, PyException>

enum AutoNumberState {
    case ANS_INIT // 初期状態
    case ANS_AUTO // 自動インクリメントモード
    case ANS_MANUAL // 指定
} /* Keep track if we're auto-numbering fields */

/* Keeps track of our auto-numbering state, and which number field we're on */
class AutoNumber {
    var an_state: AutoNumberState = .ANS_INIT
    var an_field_number: int = 0
}

/* Return 1 if an error has been detected switching between automatic
 field numbering and manual field specification, else return 0. Set
 ValueError on error. */
func autonumber_state_error(_ state: AutoNumberState, _ field_name_is_empty: Bool) -> Result<int, PyException>
{
    if (state == .ANS_MANUAL) {
        if field_name_is_empty {
            return .failure(.valueError("cannot switch from manual field specification to automatic field numbering"))
        }
    } else {
        if !field_name_is_empty {
            return .failure(.valueError("cannot switch from automatic field numbering to manual field specification"))
        }
    }
    return .success(0) // 戻り値に特に意味はない
}
func Py_UNICODE_TODECIMAL(_ c: Character) -> Int {
    if c.isdecimal(), let n = c.unicode.properties.numericValue {
        return Int(n)
    }
    return -1
}
func PyUnicode_READ_CHAR(_ str: String, _ index: Int) -> Character {
    return str[index]
}

/************************************************************************/
/***********  Format string parsing -- integers and identifiers *********/
/************************************************************************/

func get_integer(_ str: String) -> Result<Py_ssize_t, PyException>
{
    var accumulator: Py_ssize_t = 0
    
    /* empty string is an error */
    if str.isEmpty {
        return .success(-1) // error path
    }
    for c in str {
        let digitval = Py_UNICODE_TODECIMAL(c)
        if (digitval < 0) {
            return .success(-1) // error path
        }
        /*
         Detect possible overflow before it happens:
         
         accumulator * 10 + digitval > PY_SSIZE_T_MAX if and only if
         accumulator > (PY_SSIZE_T_MAX - digitval) / 10.
         */
        if (accumulator > (Int.max - digitval) / 10) {
            return .failure(.valueError("Too many decimal digits in format string"))
        }
        accumulator = accumulator * 10 + digitval
    }
    return .success(accumulator)
}

/* do the equivalent of obj.name */
func getattr(_ v: PyObject, _ name: String) -> Result<PyObject, PyException>
{
    let mirror = Mirror(reflecting: v)
    if let i = mirror.children.first(where: { $0.label == name }) {
        return .success(i.value)
    }
    return .failure(.attributeError("'\(typeName(v))' object has no attribute '\(name)'"))
}


/************************************************************************/
/******** Functions to get field objects and specification strings ******/
/************************************************************************/

class FieldNameIterator {
    /* the entire string we're parsing.  we assume that someone else
     is managing its lifetime, and that it will exist for the
     lifetime of the iterator.  can be empty */
    var str: String
    
    /* index to where we are inside field_name */
    var index: Py_ssize_t
    var end: Int {
        return str.count
    }
    
    init(_ s: String, _ start: Int) {
        self.str = s
        self.index = start
    }
}

func _FieldNameIterator_attr(_ self: FieldNameIterator) -> String
{
    var c: Py_UCS4
    
    let start = self.index
    
    /* return everything until '.' or '[' */
    while (self.index < self.end) {
        c = PyUnicode_READ_CHAR(self.str, self.index++)
        switch (c) {
            case "[", ".":
                /* backup so that we this character will be seen next time */
                self.index--
                break
            default:
                continue
        }
        break
    }
    /* end of string is okay */
    let name = self.str[start, self.index]
    return name
}

func _FieldNameIterator_item(_ self: FieldNameIterator) -> Result<String, PyException>
{
    var bracket_seen: Bool = false
    var c: Py_UCS4
    
    let start = self.index
    
    /* return everything until ']' */
    while (self.index < self.end) {
        c = PyUnicode_READ_CHAR(self.str, self.index++)
        switch (c) {
            case "]":
                bracket_seen = true
                break
            default:
                continue
        }
        break
    }
    /* make sure we ended with a ']' */
    if !bracket_seen {
        return .failure(.valueError("Missing ']' in format string"))
    }
    
    /* end of string is okay */
    /* don't include the ']' */
    let name = self.str[start, self.index - 1]
    return .success(name)
}

struct FieldNameIteratorResult {
    var is_attribute: Bool
    var name_idx: Int
    var name: String
}

enum LoopResult<T, U> {
    case success(T)
    case failure(U)
    case finish
}


/* returns 0 on error, 1 on non-error termination, and 2 if it returns a value */
func FieldNameIterator_next(_ self: FieldNameIterator) -> LoopResult<FieldNameIteratorResult, PyException>
{
    /* check at end of input */
    if (self.index >= self.end) {
        return .finish
    }
    var is_attribute: Bool = false
    var name_idx: Int = -1
    var name: String = ""
    
    switch PyUnicode_READ_CHAR(self.str, self.index++) {
        case ".":
            is_attribute = true
            name = _FieldNameIterator_attr(self)
            name_idx = -1
            break
        case "[":
            is_attribute = false
            switch _FieldNameIterator_item(self) {
                case .success(let n):
                    name = n
                case .failure(let error):
                    return .failure(error)
            }
            switch get_integer(name) {
                case .success(let i):
                    name_idx = i
                case .failure(let error):
                    return .failure(error)
            }
            break
        default:
            /* Invalid character follows ']' */
            return .failure(.valueError("Only '.' or '[' may follow ']' in format field specifier"))
    }
    
    /* empty string is an error */
    if name.isEmpty {
        return .failure(.valueError("Empty attribute in format string"))
    }
    
    return .success(.init(is_attribute: is_attribute, name_idx: name_idx, name: name))
}


/* input: field_name
 output: 'first' points to the part before the first '[' or '.'
 'first_idx' is -1 if 'first' is not an integer, otherwise
 it's the value of first converted to an integer
 'rest' is an iterator to return the rest
 */
func field_name_split(_ str: String,
                      _ auto_number: AutoNumber) -> Result<(String, Int, FieldNameIterator), PyException>
{
    var c: Py_UCS4
    var i: Py_ssize_t = 0
    let end = str.count
    var field_name_is_empty: Bool
    var using_numeric_index: Bool
    
    /* find the part up until the first '.' or '[' */
    while (i < end) {
        c = PyUnicode_READ_CHAR(str, i++)
        switch c {
            case "[", ".":
                /* backup so that we this character is available to the
                 "rest" iterator */
                i--
                break
            default:
                continue
        }
        break
    }
    
    /* set up the return values */
    let first = str[nil, i]
    let rest: FieldNameIterator = .init(str[i, end], 0)
    
    /* see if "first" is an integer, in which case it's used as an index */
    var first_idx: Py_ssize_t = -1
    switch get_integer(first) {
        case .success(let tmp):
            first_idx = tmp
        case .failure(let error):
            return .failure(error)
    }
    
    field_name_is_empty = first.isEmpty
    
    /* If the field name is omitted or if we have a numeric index
     specified, then we're doing numeric indexing into args. */
    using_numeric_index = field_name_is_empty || first_idx != -1
    
    /* We always get here exactly one time for each field we're
     processing. And we get here in field order (counting by left
     braces). So this is the perfect place to handle automatic field
     numbering if the field name is omitted. */
    
    /* Check if we need to do the auto-numbering. It's not needed if
     we're called from string.Format routines, because it's handled
     in that class by itself. */
    /* Initialize our auto numbering state if this is the first
     time we're either auto-numbering or manually numbering. */
    if (auto_number.an_state == .ANS_INIT && using_numeric_index)
    {
        auto_number.an_state = field_name_is_empty ? .ANS_AUTO: .ANS_MANUAL
    }
    
    /* Make sure our state is consistent with what we're doing
     this time through. Only check if we're using a numeric
     index. */
    if (using_numeric_index) {
        switch autonumber_state_error(auto_number.an_state, field_name_is_empty) {
            case .success:
                break
            case .failure(let error):
                return .failure(error)
        }
    }
    /* Zero length field means we want to do auto-numbering of the
     fields. */
    if field_name_is_empty {
        first_idx = (auto_number.an_field_number)++
    }
    
    return .success((first, first_idx, rest))
}


/*
 get_field_object returns the object inside {}, before the
 format_spec.  It handles getindex and getattr lookups and consumes
 the entire input string.
 */
func get_field_object(_ input: String, _ args: [Any], _ kwargs: [String: Any],
                      _ auto_number: AutoNumber) -> Result<PyObject, PyException>
{
    var obj: PyObject
    var first: String
    var index: Py_ssize_t
    var rest: FieldNameIterator
    
    switch field_name_split(input, auto_number) {
        case .success(let tmp):
            (first, index, rest) = tmp
        case .failure(let error):
            return .failure(error)
    }
    
    if (index == -1) {
        /* look up in kwargs */
        let key: String = first
        if kwargs.isEmpty {
            return .failure(.keyError(key))
        }
        guard let v = kwargs[key] else {
            return .failure(.keyError(key))
        }
        obj = v
    }
    else {
        /* If args is NULL, we have a format string with a positional field
         with only kwargs to retrieve it from. This can only happen when
         used with format_map(), where positional arguments are not
         allowed. */
        if args.isEmpty {
            return .failure(.valueError("Format string contains positional fields"))
        }
        
        /* look up in args */
        if args.count <= index {
            return .failure(.indexError("Replacement index \(index) out of range for positional args tuple"))
        }
        obj = args[index]
    }
    
    /* iterate over the rest of the field_name */
field_name: while true {
    var is_attribute: Bool = .init() // 未初期化防止用
    var index: Int = .init() // 未初期化防止用
    var name: String = .init() // 未初期化防止用
    
    switch FieldNameIterator_next(rest) {
        case .failure(let error):
            return .failure(error)
        case .finish:
            break field_name
        case .success(let result):
            is_attribute = result.is_attribute
            index = result.name_idx
            name = result.name
    }
    var tmp: PyObject?
    
    if (is_attribute) {
        /* getattr lookup "." */
        switch getattr(obj, name) {
            case .success(let o):
                tmp = o
            case .failure(let error):
                return .failure(error)
        }
    } else {
        /* getitem lookup "[]" */
        if (index == -1) {
            tmp = (obj as? [String: Any])?[name]
        } else {
            /* do the equivalent of obj[idx], where obj is not a sequence */
            if case let o as [Int: Any] = obj {
                tmp = o[index]
            }
            /* do the equivalent of obj[name] */
            else if case let o as [Any] = obj {
                tmp = o[index]
            }
            else {
                tmp = nil
            }
        }
    }
    if let t = tmp {
        obj = t
    } else {
        if index == -1 {
            return .failure(.keyError(name))
        }
        return .failure(.indexError("index out of range \(index)"))
    }
}
    /* end of iterator, this is the non-error case */
    return .success(obj)
}

/************************************************************************/
/*****************  Field rendering functions  **************************/
/************************************************************************/

/*
 render_field() is the main function in this section.  It takes the
 field object and field specification string generated by
 get_field_and_spec, and renders the field into the output string.
 
 render_field calls fieldobj.__format__(format_spec) method, and
 appends to the output.
 */
func render_field(_ fieldobj: PyObject, _ format_spec: String) -> FormatResult
{
    
    /* If we know the type exactly, skip the lookup of __format__ and just
     call the formatter directly. */
    switch fieldobj {
        case let obj as PSFormattableString:
            return _PyUnicode_FormatAdvancedWriter(obj, format_spec)
        case let obj as PSFormattableInteger:
            return _PyLong_FormatAdvancedWriter(obj, format_spec)
        case let obj as PSFormattableFloatingPoint:
            return _PyFloat_FormatAdvancedWriter(obj, format_spec)
        case let obj as PSFormattableComplex:
            return _PyComplex_FormatAdvancedWriter(obj, format_spec)
        default:
            /* We need to create an object out of the pointers we have, because
             __format__ takes a string/unicode object for format_spec. */
            return .success(String(describing: fieldobj))
    }
}
struct ParseResult {
    var field_name: String
    var format_spec: String = ""
    var format_spec_needs_expanding: Bool
    var conversion: Py_UCS4 = "\0"
}

extension ParseResult {
    init(field_name: String, format_spec_needs_expanding: Bool){
        self.field_name = field_name
        self.format_spec_needs_expanding = format_spec_needs_expanding
    }
}

func parse_field(_ str: MarkupIterator) -> Result<ParseResult, PyException>
{
    /* Note this function works if the field name is zero length,
     which is good.  Zero length field names are handled later, in
     field_name_split. */
    
    var c: Py_UCS4 = "\0"
    
    /* initialize these, as they may be empty */
    var result = ParseResult(field_name: "", format_spec_needs_expanding: false)
    
    /* Search for the field name.  it's terminated by the end of
     the string, or a ':' or '!' */
    let start = str.start
    while (str.start < str.end) {
        c = PyUnicode_READ_CHAR(str.str, str.start++)
        switch c {
            case "{":
                return .failure(.valueError("unexpected '{' in field name"))
            case "[":
                while str.start < str.end {
                    if (PyUnicode_READ_CHAR(str.str, str.start) == "]") {
                        break
                    }
                    str.start++
                }
                continue
            case "}", ":", "!":
                break
            default:
                continue
        }
        break
    }
    
    result.field_name = str.str[start, str.start - 1] // フィールド名に相当する部分の部分の字列の切り出し
    if (c == "!" || c == ":") {
        /* we have a format specifier and/or a conversion */
        /* don't include the last character */
        
        /* see if there's a conversion specifier */
        if (c == "!") {
            /* there must be another character present */
            if (str.start >= str.end) {
                return .failure(.valueError("end of string while looking for conversion specifier"))
            }
            result.conversion = PyUnicode_READ_CHAR(str.str, str.start++)
            
            if (str.start < str.end) {
                c = PyUnicode_READ_CHAR(str.str, str.start++)
                if (c == "}") {
                    return .success(result)
                }
                if (c != ":") {
                    return .failure(.valueError("expected ':' after conversion specifier"))
                }
            }
        }
        let start = str.start
        var count = 1
        while (str.start < str.end) {
            c = PyUnicode_READ_CHAR(str.str, str.start++)
            switch c {
                case "{":
                    result.format_spec_needs_expanding = true
                    count++
                    break
                case "}":
                    count--
                    if count == 0 {
                        result.format_spec = str.str[start, str.start - 1] // フォーマット指定子に相当する部分文字列の切り出し
                        return .success(result)
                    }
                    break
                default:
                    break
            }
        }
        
        return .failure(.valueError("unmatched '{' in format spec"))
    }
    else if (c != "}") {
        return .failure(.valueError("expected '}' before end of string"))
    }
    
    return .success(result)
}

class MarkupIterator {
    let str: String
    var start: Int // 読み取りの開始位置
    var end: Int {
        return str.count
    }
    init(_ str: String, _ start: Int) {
        self.str = str
        self.start = start
    }
}

/* returns 0 on error, 1 on non-error termination, and 2 if it got a
 string (or something to be expanded) */

/* returns a tuple:
 (literal, field_name, format_spec, conversion)
 
 literal is any literal text to output.  might be zero length
 field_name is the string before the ':'.  might be None
 format_spec is the string after the ':'.  mibht be None
 conversion is either None, or the string after the '!'
 */

struct MarkupIteratorNextResult {
    var format_spec_needs_expanding: Bool
    var field_present: Bool
    var literal: String
    var field_name: String
    var format_spec: String
    var conversion: Py_UCS4
}

func MarkupIterator_next(_ self: MarkupIterator) -> LoopResult<MarkupIteratorNextResult, PyException>
{
    var markup_follows: Bool = false
    
    /* initialize all of the output variables */
    var result = MarkupIteratorNextResult(format_spec_needs_expanding: false, field_present: false, literal: "", field_name: "", format_spec: "", conversion: "\0")
    
    /* No more input, end of iterator.  This is the normal exit
     path. */
    if (self.start >= self.end) {
        return .finish
    }
    
    let start: Py_ssize_t = self.start
    
    /* First read any literal text. Read until the end of string, an
     escaped '{' or '}', or an unescaped '{'.  In order to never
     allocate memory and so I can just pass pointers around, if
     there's an escaped '{' or '}' then we'll return the literal
     including the brace, but no format object.  The next time
     through, we'll return the rest of the literal, skipping past
     the second consecutive brace. */
    var c: Py_UCS4 = "\0"
    for i in self.str[start, nil] {
        c = i
        self.start++
        switch c {
            case "{", "}":
                markup_follows = true
                break
            default:
                continue
        }
        break
    }
    
    let at_end: Bool = self.start >= self.end
    var len: Py_ssize_t = self.start - start
    
    if ((c == "}") && (at_end ||
                       (c != self.str[self.start]))) {
        return .failure(.valueError("Single '}' encountered in format string"))
    }
    if (at_end && c == "{") {
        return .failure(.valueError("Single '{' encountered in format string"))
    }
    if (!at_end) {
        if (c == self.str[self.start]) {
            /* escaped } or {, skip it in the input.  there is no
             markup object following us, just this literal text */
            self.start++
            markup_follows = false
        }
        else {
            len--
        }
    }
    
    /* record the literal text */
    result.literal = self.str[start, start + len]
    
    if (!markup_follows) {
        return .success(result)
    }
    
    /* this is markup; parse the field */
    result.field_present = true
    switch parse_field(self) {
        case .success(let r):
            result.conversion = r.conversion
            result.format_spec = r.format_spec
            result.field_name = r.field_name
            result.format_spec_needs_expanding = r.format_spec_needs_expanding
        case .failure(let error):
            return .failure(error)
    }
    return .success(result)
}


/* do the !r or !s conversion on obj */
func do_conversion(_ obj: PyObject, _ conversion: Py_UCS4) -> FormatResult
{
    /* XXX in pre-3.0, do we need to convert this to unicode, since it
     might have returned a string? */
    switch (conversion) {
        case "r", "s", "a":
            if let obj = obj as? PSFormattable {
                return .success(obj.convertField(conversion))
            }
            return .success("nil")
        default:
            if conversion.isRegularASCII {
                /* It's the ASCII subrange; casting to char is safe
                 (assuming the execution character set is an ASCII
                 superset). */
                return .failure(.valueError("Unknown conversion specifier \(conversion)"))
            }
            return .failure(.valueError("Unknown conversion specifier \\x\(hex(conversion.unicode.value, false))"))
    }
}

/* given:
 
 {field_name!conversion:format_spec}
 
 compute the result and write it to output.
 format_spec_needs_expanding is an optimization.  if it's false,
 just output the string directly, otherwise recursively expand the
 format_spec string.
 
 field_name is allowed to be zero length, in which case we
 are doing auto field numbering.
 */

func output_markup(_ field_name: String,
                   _ format_spec: String,
                   _ format_spec_needs_expanding: Bool,
                   _ conversion: Py_UCS4,
                   _ args: [Any],
                   _ kwargs: [String: Any],
                   _ recursion_depth: int,
                   _ auto_number: AutoNumber) -> FormatResult
{
    var fieldobj: PyObject
    var actual_format_spec: String
    
    /* convert field_name to an object */
    switch get_field_object(field_name, args, kwargs, auto_number) {
        case .success(let o):
            fieldobj = o
        case .failure(let error):
            return .failure(error)
    }
    
    if (conversion != "\0") {
        switch do_conversion(fieldobj, conversion) {
            case .success(let s):
                fieldobj = s
            case .failure(let error):
                return .failure(error)
        }
    }
    
    /* if needed, recurively compute the format_spec */
    if (format_spec_needs_expanding) {
        switch build_string(format_spec, args, kwargs, recursion_depth - 1, auto_number) {
            case .success(let expanded_format_spec):
                actual_format_spec = expanded_format_spec
            case .failure(let error):
                return .failure(error)
        }
    }
    else {
        actual_format_spec = format_spec
    }
    switch render_field(fieldobj, actual_format_spec) {
        case .success(let str):
            return .success(str)
        case .failure(let error):
            return .failure(error)
    }
}

/*
 do_markup is the top-level loop for the format() method.  It
 searches through the format string for escapes to markup codes, and
 calls other functions to move non-markup text to the output,
 and to perform the markup to the output.
 */



func do_markup(_ input: String, _ args: [Any], _ kwargs: [String: Any],
               _ recursion_depth: int, _ auto_number: AutoNumber) -> FormatResult
{
    let iter: MarkupIterator = .init(input, 0)
    var result: MarkupIteratorNextResult
    var markuped: String = ""
mark_up: while true {
    switch MarkupIterator_next(iter) {
        case .finish:
            break mark_up
        case .failure(let error):
            return .failure(error)
        case .success(let r):
            result = r
            if !result.literal.isEmpty {
                markuped.append(result.literal)
            }
            
            if result.field_present {
                switch output_markup(result.field_name,
                                     result.format_spec,
                                     result.format_spec_needs_expanding,
                                     result.conversion,
                                     args,
                                     kwargs,
                                     recursion_depth,
                                     auto_number) {
                    case .success(let str):
                        markuped.append(str)
                    case .failure(let error):
                        return .failure(error)
                }
            }
    }
}
    return .success(markuped)
}


/*
 build_string allocates the output string and then
 calls do_markup to do the heavy lifting.
 */
func build_string(_ input: String, _ args: [Any], _ kwargs: [String: Any],
                  _ recursion_depth: int, _ auto_number: AutoNumber) -> FormatResult
{
    /* check the recursion level */
    if (recursion_depth <= 0) {
        return .failure(.valueError("Max string recursion exceeded"))
    }
    return do_markup(input, args, kwargs, recursion_depth, auto_number)
}

/************************************************************************/
/*********** main routine ***********************************************/
/************************************************************************/

/* this is the main entry point */
func do_string_format(_ self: String, _ args: [Any], _ kwargs: [String: Any]) throws -> String
{
    
    /* PEP 3101 says only 2 levels, so that
     "{0:{1}}".format('abc', 's')            # works
     "{0:{1:{2}}}".format('abc', 's', '')    # fails
     */
    let recursion_depth: int = 2
    
    let auto_number: AutoNumber = .init()
    switch build_string(self, args, kwargs, recursion_depth, auto_number) {
        case .success(let s):
            return s
        case .failure(let error):
            throw error
    }
}

/* Raises an exception about an unknown presentation type for this
 * type. */
extension Py_UCS4 {
    var isRegularASCII: Bool {
        let v = self.unicode.value
        return 32 < v && v < 128
    }
}
func unknown_presentation_type(_ presentation_type: Py_UCS4,
                               _ type_name: String) -> PyException
{
    /* %c might be out-of-range, hence the two cases. */
    if (presentation_type.isRegularASCII) {
        return .valueError("Unknown format code '\(presentation_type)' for object of type '\(type_name)'")
    }
    let hex = String(format: "%x", presentation_type.unicode.value)
    return .valueError("Unknown format code '\\x\(hex)' for object of type '\(type_name)'")
}

func invalid_thousands_separator_type(_ specifier: Character, _ presentation_type: Py_UCS4) -> PyException
{
    assert(specifier == "," || specifier == "_")
    if (presentation_type.isRegularASCII) {
        return .valueError("Cannot specify '\(specifier)' with '\(presentation_type)'.")
    }
    let hex = String(format: "%x", presentation_type.unicode.value)
    return .valueError("Cannot specify '\(specifier)' with '\\x\(hex)'.")
}

func invalid_comma_and_underscore() -> PyException
{
    return .valueError("Cannot specify both ',' and '_'.")
}

/*
 get_integer consumes 0 or more decimal digit characters from an
 input string, updates *result with the corresponding positive
 integer, and returns the number of digits consumed.
 
 returns -1 on error.
 */
func get_integer(_ str: String,
                 _ start_pos: Py_ssize_t) -> Result<(int, int), PyException>
{
    var accumulator: Py_ssize_t = 0
    var numdigits: int = 0
    let end = str.count
    var ppos = start_pos
    while ppos < end {
        let digitval = Py_UNICODE_TODECIMAL(str[ppos])
        if digitval < 0 {
            break
        }
        /*
         Detect possible overflow before it happens:
         
         accumulator * 10 + digitval > PY_SSIZE_T_MAX if and only if
         accumulator > (PY_SSIZE_T_MAX - digitval) / 10.
         */
        if (accumulator > (Int.max - digitval) / 10) {
            
            return .failure(.valueError("Too many decimal digits in format string"))
        }
        accumulator = accumulator * 10 + digitval
        ppos++
        numdigits++
    }
    return .success((numdigits, accumulator)) // 文字の幅、文字の数値表現
}

/************************************************************************/
/*********** standard format specifier parsing **************************/
/************************************************************************/

/* returns true if this character is a specifier alignment token */
func is_alignment_token(_ c: Character) -> Bool
{
    switch (c) {
        case "<", ">", "=", "^":
            return true
        default:
            return false
    }
}

/* returns true if this character is a sign element */
func is_sign_element(_ c: Character) -> Bool
{
    switch (c) {
        case " ", "+", "-":
            return true
        default:
            return false
    }
}

/* Locale type codes. LT_NO_LOCALE must be zero. */
enum LocaleType: Character {
    case LT_NO_LOCALE = "\0"
    case LT_DEFAULT_LOCALE = ","
    case LT_UNDERSCORE_LOCALE = "_"
    case LT_UNDER_FOUR_LOCALE = "`"
    case LT_CURRENT_LOCALE = "a"
}

struct InternalFormatSpec {
    var fill_char: Py_UCS4 = " "
    var align: Py_UCS4
    var alternate: Bool = false
    var sign: Py_UCS4 = "\0"
    var width: Py_ssize_t = -1
    var thousands_separators: LocaleType = .LT_NO_LOCALE
    var precision: Py_ssize_t = -1
    var type: Py_UCS4
}
extension InternalFormatSpec {
    init(align: Py_UCS4, type: Py_UCS4) {
        self.align = align
        self.type = type
    }
}
extension InternalFormatSpec: CustomDebugStringConvertible {
    /* Occasionally useful for debugging. Should normally be commented out. */
    var debugDescription: String {
        return String(format: "internal format spec: fill_char \(fill_char))\n") +
        String(format: "internal format spec: align \(align)\n") +
        String(format: "internal format spec: alternate \(alternate)\n") +
        String(format: "internal format spec: sign \(sign)\n") +
        String(format: "internal format spec: width %zd\n", width) +
        String(format: "internal format spec: thousands_separators \(thousands_separators)\n") +
        String(format: "internal format spec: precision %zd\n", precision) +
        String(format: "internal format spec: type \(type)\n")
    }
}


/*
 ptr points to the start of the format_spec, end points just past its end.
 fills in format with the parsed information.
 returns 1 on success, 0 on failure.
 if failure, sets the exception
 */
func parse_internal_render_format_spec(_ format_spec: String,
                                       _ default_format_spec: InternalFormatSpec) -> Result<InternalFormatSpec, PyException>
{
    if format_spec.isEmpty {
        return .success(default_format_spec)
    }
    var format: InternalFormatSpec = default_format_spec
    
    var pos = 0
    let end = format_spec.count
    
    var consumed: Py_ssize_t
    var align_specified: Bool = false
    var fill_char_specified: Bool = false
    
    /* If the second char is an alignment token,
     then parse the fill char */
    if let align = format_spec.at(pos + 1), is_alignment_token(align) {
        // 現在の対象から二文字先にアラインメント指定があればアラインメントの指定に加えて、
        // パディング文字の指定もあることがわかる
        format.align = align
        format.fill_char = format_spec[pos]
        fill_char_specified = true
        align_specified = true
        pos += 2
    }
    else if let align = format_spec.at(pos), is_alignment_token(align) {
        format.align = align
        align_specified = true
        ++pos
    }
    
    /* Parse the various sign options */
    if let element = format_spec.at(pos), is_sign_element(element) {
        format.sign = element
        ++pos
    }
    
    /* If the next character is #, we're in alternate mode.  This only
     applies to integers. */
    if let c = format_spec.at(pos), c == "#" {
        format.alternate = true
        ++pos
    }
    
    /* The special case for 0-padding (backwards compat) */
    if let c = format_spec.at(pos), c == "0", !fill_char_specified {
        format.fill_char = "0"
        if !align_specified {
            format.align = "="
        }
        ++pos
    }
    
    switch get_integer(format_spec, pos) {
        case .success(let t):
            (consumed, format.width) = t
            pos += consumed
        case .failure(let error):
            /* Overflow error. Exception already set. */
            return .failure(error)
    }
    
    /* If consumed is 0, we didn't consume any characters for the
     width. In that case, reset the width to -1, because
     get_integer() will have set it to zero. -1 is how we record
     that the width wasn't specified. */
    if consumed == 0 {
        format.width = -1
    }
    
    /* Comma signifies add thousands separators */
    if let c = format_spec.at(pos), c == "," {
        format.thousands_separators = .LT_DEFAULT_LOCALE
        ++pos
    }
    /* Underscore signifies add thousands separators */
    if let c = format_spec.at(pos), c == "_" {
        if (format.thousands_separators != .LT_NO_LOCALE) {
            return .failure(invalid_comma_and_underscore())
        }
        format.thousands_separators = .LT_UNDERSCORE_LOCALE
        ++pos
    }
    if let c = format_spec.at(pos), c == "," {
        return .failure(invalid_comma_and_underscore())
    }
    
    /* Parse field precision */
    if let c = format_spec.at(pos), c == "." {
        ++pos
        
        switch get_integer(format_spec, pos) {
            case .success(let t):
                (consumed, format.precision) = t
                pos += consumed
            case .failure(let error):
                /* Overflow error. Exception already set. */
                return .failure(error)
        }
        /* Not having a precision after a dot is an error. */
        if consumed == 0 {
            return .failure(.valueError("Format specifier missing precision"))
        }
        
    }
    
    /* Finally, parse the type field. */
    if end - pos > 1 {
        /* More than one char remain, invalid format specifier. */
        return .failure(.valueError("Invalid format specifier"))
    }
    
    if end - pos == 1 {
        format.type = format_spec.at(pos)!
        ++pos
    }
    
    /* Do as much validating as we can, just by looking at the format
     specifier.  Do not take into account what type of formatting
     we're doing (int, float, string). */
    
    if (format.thousands_separators != .LT_NO_LOCALE) {
        switch (format.type) {
            case "d", "e", "f", "g", "E", "G", "%", "F", "\0":
                /* These are allowed. See PEP 378.*/
                break
            case "b", "o", "x", "X":
                /* Underscores are allowed in bin/oct/hex. See PEP 515. */
                if (format.thousands_separators == .LT_UNDERSCORE_LOCALE) {
                    /* Every four digits, not every three, in bin/oct/hex. */
                    format.thousands_separators = .LT_UNDER_FOUR_LOCALE
                    break
                }
                fallthrough
            default:
                return .failure(invalid_thousands_separator_type(format.thousands_separators.rawValue, format.type))
        }
    }
    
    return .success(format)
}

let Py_UNREACHABLE = "Py_FatalError(\"Unreachable C code path reached\")"
/* Do the padding, and return a pointer to where the caller-supplied
 content goes. */
func fill_padding(_ value: String,
                  _ align: Character,
                  _ fill_char: Py_UCS4,
                  _ width: Py_ssize_t) -> String
{
    switch align {
        case ">":
            return value.rjust(width, fillchar: fill_char)
        case "^":
            return value.center(width, fillchar: fill_char)
        case "<", "=":
            return value.ljust(width, fillchar: fill_char)
        default:
            return Py_UNREACHABLE
    }
}

/************************************************************************/
/*********** common routines for numeric formatting *********************/
/************************************************************************/

/* Locale info needed for formatting integers and the part of floats
 before and including the decimal. Note that locales only support
 8-bit chars, not unicode. */
struct LocaleInfo {
    var decimal_point: String = ""
    var thousands_sep: String = ""
    var grouping: [Int8] = []
}
/* _PyUnicode_InsertThousandsGrouping() helper functions */

struct GroupGenerator {
    let grouping: [Int8]
    var previous: Int = .max
    var i: Py_ssize_t = 0 /* Where we're currently pointing in grouping. */
    let max: Int = CHAR_MAX
    init(_ grouping: [Int8]) {
        self.grouping = grouping
    }
    mutating func next() -> Int {
        /* Note that we don't really do much error checking here. If a
         grouping string contains just CHAR_MAX, for example, then just
         terminate the generator. That shouldn't happen, but at least we
         fail gracefully. */
        if grouping.count > i {
            let ch = Int(self.grouping[self.i])
            switch ch {
                case 0:
                    return self.previous
                case max:
                    /* Stop the generator. */
                    return 0
                default:
                    self.previous = ch
                    self.i++
                    return ch
            }
        }
        return previous
    }
}

/* describes the layout for an integer, see the comment in
 calc_number_widths() for details */
struct NumberFieldWidths {
    var sign: String
    var need_sign: Bool /* number of digits needed for sign (0/1) */
    var fill_char: Character
}

func PyOS_double_to_string(_ val: double,
                           _ format_code: Character,
                           _ precision: int,
                           _ sign:Bool,
                           _ addDot0:Bool,
                           _ alt:Bool) -> String
{
    var format: String
    var buf: String
    var upper: Bool = false
    // to mutable
    var format_code: Character = format_code
    var precision: int = precision
    
    /* Validate format_code, and map upper and lower case */
    switch format_code {
        case "e", /* exponent */
            "f", /* fixed */
            "g": /* general */
            break
        case "E":
            upper = true
            format_code = "e"
            break
        case "F":
            upper = true
            format_code = "f"
            break
        case "G":
            upper = true
            format_code = "g"
            break
        case "r": /* repr format */
            /* Supplied precision is unused, must be 0. */
            if precision != 0 {
                fatalError("PyErr_BadInternalCall()")
            }
            /* The repr() precision (17 significant decimal digits) is the
             minimal number that is guaranteed to have enough precision
             so that if the number is read back in the exact same binary
             value is recreated.  This is true for IEEE floating point
             by design, and also happens to work for all other modern
             hardware. */
            precision = 16 // 17
            format_code = "g"
            break
        default:
            fatalError("PyErr_BadInternalCall()")
    }
    
    /* Here's a quick-and-dirty calculation to figure out how big a buffer
     we need.  In general, for a finite float we need:
     
     1 byte for each digit of the decimal significand, and
     
     1 for a possible sign
     1 for a possible decimal point
     2 for a possible [eE][+-]
     1 for each digit of the exponent;  if we allow 19 digits
     total then we're safe up to exponents of 2**63.
     1 for the trailing nul byte
     
     This gives a total of 24 + the number of digits in the significand,
     and the number of digits in the significand is:
     
     for 'g' format: at most precision, except possibly
     when precision == 0, when it's 1.
     for 'e' format: precision+1
     for 'f' format: precision digits after the point, at least 1
     before.  To figure out how many digits appear before the point
     we have to examine the size of the number.  If fabs(val) < 1.0
     then there will be only one digit before the point.  If
     fabs(val) >= 1.0, then there are at most
     
     1+floor(log10(ceiling(fabs(val))))
     
     digits before the point (where the 'ceiling' allows for the
     possibility that the rounding rounds the integer part of val
     up).  A safe upper bound for the above quantity is
     1+floor(exp/3), where exp is the unique integer such that 0.5
     <= fabs(val)/2**exp < 1.0.  This exp can be obtained from
     frexp.
     
     So we allow room for precision+1 digits for all formats, plus an
     extra floor(exp/3) digits for 'f' format.
     
     */
    
    /* Handle nan and inf. */
    if val.isNaN {
        buf = "nan"
    } else if val.isInfinite {
        if (copysign(1.0, val) == 1.0) {
            buf = "inf"
        }
        else {
            buf = "-inf"
        }
    } else {
        format = String(format: "%%\(alt ? "#" : "").%i%c", precision, format_code.unicode.value)
        buf = String(format: format, val, precision)
        if alt && buf.find(".") != -1 {
            var drop = buf.count - 1
            while buf[drop] == "0" && buf[drop - 1] != "." {
                buf.removeLast()
                drop -= 1
            }
        }
        if addDot0 {
            if buf.find(".") == -1 {
                buf += ".0"
            }
        }
    }
    
    /* Add sign when requested.  It's convenient (esp. when formatting
     complex numbers) to include a sign even for inf and nan. */
    if sign && buf[0] != "-" {
        buf = "+" + buf
    }
    if upper {
        /* Convert to upper case. */
        buf = buf.upper()
    }
    
    return buf
}

/**
 * InsertThousandsGrouping:
 * @writer: Unicode writer.
 * @n_buffer: Number of characters in @buffer.
 * @digits: Digits we're reading from. If count is non-NULL, this is unused.
 * @d_pos: Start of digits string.
 * @n_digits: The number of digits in the string, in which we want
 *            to put the grouping chars.
 * @min_width: The minimum width of the digits in the output string.
 *             Output will be zero-padded on the left to fill.
 * @grouping: see definition in localeconv().
 * @thousands_sep: see definition in localeconv().
 *
 * There are 2 modes: counting and filling. If @writer is NULL,
 *  we are in counting mode, else filling mode.
 * If counting, the required buffer size is returned.
 * If filling, we know the buffer will be large enough, so we don't
 *  need to pass in the buffer size.
 * Inserts thousand grouping characters (as defined by grouping and
 *  thousands_sep) into @writer.
 *
 * Return value: -1 on error, number of characters otherwise.
 **/

func _PyUnicode_InsertThousandsGrouping(
    _ digits: String,
    _ grouping: [Int8],
    _ thousands_sep: String) -> String
{
    if thousands_sep.isEmpty || grouping.isEmpty {
        return digits
    }
    var groupgen: GroupGenerator = .init(grouping)
    
    /* if digits are not grouped, thousands separator
     should be an empty string */
    var buf = ""
    var len = groupgen.next()
    var i = -1
    for ch in digits.reversed() {
        i += 1
        if len != 0 && len == i {
            buf.append(thousands_sep)
            i = 0
            len = groupgen.next()
        }
        buf.append(ch)
    }
    return String(buf.reversed())
}

/* the output will look like:
 |                                                                                         |
 | <lpadding> <sign> <prefix> <spadding> <grouped_digits> <decimal> <remainder> <rpadding> |
 |                                                                                         |
 
 sign is computed from format->sign and the actual
 sign of the number
 
 prefix is given (it's for the '0x' prefix)
 
 digits is already known
 
 the total width is either given, or computed from the
 actual digits
 
 only one of lpadding, spadding, and rpadding can be non-zero,
 and it's calculated from the width and other fields
 */
func calc_number_widths(
    _ sign_char: Py_UCS4,
    _ format: InternalFormatSpec
) -> NumberFieldWidths {
    var spec: NumberFieldWidths = .init(sign: "", need_sign: false, fill_char: format.fill_char)
    
    /* compute the various parts we're going to write */
    switch format.sign {
        case "+":
            /* always put a + or - */
            spec.sign = (sign_char == "-" ? "-" : "+")
            spec.need_sign = true
        case " ":
            spec.sign = (sign_char == "-" ? "-" : " ")
            spec.need_sign = true
        default:
            /* Not specified, or the default (-) */
            if (sign_char == "-") {
                spec.sign = "-"
                spec.need_sign = true
            }
    }
    
    return spec
}

/* Fill in the digit parts of a number's string representation,
 as determined in calc_number_widths().
 Return -1 on error, or 0 on success. */
func fill_number(_ spec: NumberFieldWidths,
                 _ digits: String,
                 _ format: InternalFormatSpec,
                 _ prefix: String,
                 _ fill_char: Py_UCS4,
                 _ locale: LocaleInfo,
                 _ toupper: Bool) -> String
{
    var (digits, dot, remine) = digits.partition(locale.decimal_point)
    digits = _PyUnicode_InsertThousandsGrouping(digits, locale.grouping, locale.thousands_sep)
    /* Used to keep track of digits, decimal, and remainder. */
    digits = prefix + digits + dot + remine
    
    /* Only for type 'c' special case, it has no digits. */
    if toupper {
        digits = digits.upper()
    }
    
    return digits
}

func number_just(_ digits: String, _ format: InternalFormatSpec, _ spec: NumberFieldWidths) -> String {
    /* Some padding is needed. Determine if it's left, space, or right. */
    let sign = spec.sign
    switch format.align {
        case "<":
            return (sign + digits).ljust(format.width, fillchar: spec.fill_char)
        case "^":
            return (sign + digits).center(format.width, fillchar: spec.fill_char)
        case "=":
            return sign + digits.rjust(format.width - (spec.need_sign ? 1 : 0), fillchar: "0")
        case ">":
            return (sign + digits).rjust(format.width, fillchar: spec.fill_char)
        default:
            /* Shouldn't get here, but treat it as '>' */
            return Py_UNREACHABLE
    }
}

/* Find the decimal point character(s?), thousands_separator(s?), and
 grouping description, either for the current locale if type is
 LT_CURRENT_LOCALE, a hard-coded locale if LT_DEFAULT_LOCALE or
 LT_UNDERSCORE_LOCALE/LT_UNDER_FOUR_LOCALE, or none if LT_NO_LOCALE. */
func get_locale_info(_ type: LocaleType) -> LocaleInfo
{
    var locale_info: LocaleInfo = .init()
    switch (type) {
        case .LT_CURRENT_LOCALE:
            (locale_info.decimal_point,
             locale_info.thousands_sep,
             locale_info.grouping) = getLocalInfo()
        case .LT_DEFAULT_LOCALE,
                .LT_UNDERSCORE_LOCALE,
                .LT_UNDER_FOUR_LOCALE:
            locale_info.decimal_point = "."
            locale_info.thousands_sep = type == .LT_DEFAULT_LOCALE ? "," : "_"
            if (type != .LT_UNDER_FOUR_LOCALE) {
                locale_info.grouping = [3] /* Group every 3 characters.  The
                                            (implicit) trailing 0 means repeat
                                            infinitely. */
            } else {
                locale_info.grouping = [4] /* Bin/oct/hex group every four. */
            }
            break
        case .LT_NO_LOCALE:
            locale_info.decimal_point = "."
            locale_info.thousands_sep = ""
            let no_grouping = [Int8(CHAR_MAX)] // char_max?
            locale_info.grouping = no_grouping
            break
    }
    return locale_info
}

func getLocalInfo() -> (String, String, [Int8]) {
    // TODO:remove force unwrap
    // TODO: \0 to ""(empty String)
    if let local = localeconv() {
        let lc = local.pointee
        if let d = lc.decimal_point, let dp = UnicodeScalar(UInt16(d.pointee)) {
            let decimal_point = String(dp)
            if let t = lc.thousands_sep, let ts = UnicodeScalar(UInt32(t.pointee)) {
                let thousands_sep = String(ts)
                var grouping: [Int8] = []
                if let g = lc.grouping {
                    var i = 0
                    while i != CHAR_MAX {
                        let p = g.advanced(by: i)
                        grouping.append(p.pointee)
                        i += 1
                    }
                }
                return (decimal_point, thousands_sep, grouping)
            }
            return (decimal_point, ",", [])
        }
    }
    return (".", ",", [])
}


protocol PSFormattable {
    var str: String { get }
    var repr: String { get }
    var ascii: String { get }
    var defaultInternalFormatSpec: InternalFormatSpec { get }
    func convertField(_ conversion: Character) -> String
    func objectFormat(_ format: InternalFormatSpec) -> FormatResult
}
extension PSFormattable {
    var str: String { return String(describing: self) }
    var repr: String { return String(describing: self) }
    var ascii: String { return String(describing: self) }
    
    func convertField(_ conversion: Character) -> String {
        switch conversion {
            case "s":
                return str
            case "r":
                return repr
            case "a":
                return ascii
            default:
                return String(describing: self)
        }
    }
}

protocol PSFormattableString: PSFormattable {
    var formattableString: String { get }
}
extension PSFormattableString {
    var defaultInternalFormatSpec: InternalFormatSpec {
        return InternalFormatSpec(align: "<", type: "s")
    }
    /************************************************************************/
    /*********** string formatting ******************************************/
    /************************************************************************/
    func objectFormat(_ format: InternalFormatSpec) -> FormatResult {
        let value = self.formattableString
        
        var len = value.count
        
        /* sign is not allowed on strings */
        if (format.sign != "\0") {
            return .failure(.valueError("Sign not allowed in string format specifier"))
        }
        
        /* alternate is not allowed on strings */
        if format.alternate {
            return .failure(.valueError("Alternate form (#) not allowed in string format specifier"))
        }
        
        /* '=' alignment not allowed on strings */
        if (format.align == "=") {
            return .failure(.valueError("'=' alignment not allowed in string format specifier"))
        }
        
        if ((format.width == -1 || format.width <= len)
            && (format.precision == -1 || format.precision >= len)) {
            /* Fast path */
            return .success(value)
        }
        
        /* if precision is specified, output no more that format.precision
         characters */
        if (format.precision >= 0 && len >= format.precision) {
            len = format.precision
        }
        
        /* Write into that space. First the padding. */
        return .success(fill_padding(value[0, len], format.align, format.fill_char, format.width))
    }
}
extension String: PSFormattableString {
    var formattableString: String { return self }
    var str: String { return self }
    var repr: String { return "'\(self)'" }
    var ascii: String { return "'\(self)'" }
}

@inlinable
func bin<Subject>(_ i: Subject, _ alternate: Bool = true) -> String where Subject: BinaryInteger {
    return (alternate ? "0b" : "") + String(i, radix: 2, uppercase: false)
}
@inlinable
func oct<Subject>(_ i: Subject, _ alternate: Bool = true) -> String where Subject: BinaryInteger {
    return (alternate ? "0o" : "") + String(i, radix: 8, uppercase: false)
}
@inlinable
func hex<Subject>(_ i: Subject, _ alternate: Bool = true) -> String where Subject: BinaryInteger {
    return (alternate ? "0x" : "") + String(i, radix: 16, uppercase: false)
}
let alternates = [
    2: "0b",
    8: "0o",
    10: "",
    16: "0x",
]
func longFormat<Subject>(_ i: Subject, radix: Int, alternate: Bool = true) -> String where Subject: BinaryInteger {
    return (alternate ? alternates[radix, default: ""] : "") + String(i, radix: radix, uppercase: false)
}

protocol PSFormattableInteger: PSFormattable {
    var formatableInteger: Int { get }
}
extension PSFormattableInteger {
    var defaultInternalFormatSpec: InternalFormatSpec {
        return InternalFormatSpec(align: ">", type: "d")
    }
    /************************************************************************/
    /*********** long formatting ********************************************/
    /************************************************************************/
    
    func objectFormat(_ format: InternalFormatSpec) -> FormatResult {
        let value = self.formatableInteger
        var tmp: String = ""
        var sign_char: Py_UCS4 = "\0"
        var prefix_tmp: String = ""
        
        /* no precision allowed on integers */
        if (format.precision != -1) {
            return .failure(.valueError("Precision not allowed in integer format specifier"))
        }
        
        /* special case for character formatting */
        if (format.type == "c") {
            /* error to specify a sign */
            if (format.sign != "\0") {
                return .failure(.valueError("Sign not allowed with integer format specifier 'c'"))
            }
            /* error to request alternate format */
            if format.alternate {
                return .failure(.valueError("Alternate form (#) not allowed with integer format specifier 'c'"))
            }
            
            /* taken from unicodeobject.c formatchar() */
            /* Integer input truncated to a character */
            if (value < 0 || value > 0x10ffff) {
                return .failure(.overflowError("%c arg not in range(0x110000)"))
            }
            tmp = String(Py_UCS4(value))
        } else {
            let isDefault = (
                format.sign != "+" &&
                format.sign != " " &&
                format.width == -1 &&
                format.type != "X" &&
                format.type != "n" &&
                format.thousands_separators == .LT_NO_LOCALE)
            var base: int
            
            /* Compute the base and how many characters will be added by
             PyNumber_ToBase */
            switch (format.type) {
                case "b":
                    base = 2
                    prefix_tmp = format.alternate ? "0b" : ""
                    break
                case "o":
                    base = 8
                    prefix_tmp = format.alternate ? "0o" : ""
                    break
                case "x", "X":
                    base = 16
                    prefix_tmp = format.alternate ? "0x" : ""
                    break
                case "d", "n":
                    fallthrough
                default: /* shouldn't be needed, but stops a compiler warning */
                    base = 10
                    break
                    
            }
            
            if isDefault {
                /* Fast path */
                return .success(longFormat(value, radix: base, alternate: format.alternate))
            }
            
            /* Do the hard part, converting to a string in a given base */
            tmp = String(value, radix: base, uppercase: false)
            
            
            /* Is a sign character present in the output?  If so, remember it
             and skip it */
            if (PyUnicode_READ_CHAR(tmp, 0) == "-") {
                sign_char = "-"
                tmp.removeFirst()
            }
        }
        
        /* Determine the grouping, separator, and decimal point, if any. */
        /* Locale settings, either from the actual locale or
         from a hard-code pseudo-locale */
        let locale: LocaleInfo = get_locale_info(format.type == "n" ? .LT_CURRENT_LOCALE:
                                                    format.thousands_separators)
        /* Calculate how much memory we'll need. */
        let spec: NumberFieldWidths = calc_number_widths(sign_char, format)
        
        tmp = fill_number(spec, tmp, format, prefix_tmp, format.fill_char, locale, format.type == "X")
        tmp = number_just(tmp, format, spec)
        return .success(tmp)
    }
}

protocol PSFormattableFloatingPoint: PSFormattable {
    var formatableFloatingPoint: Double { get }
}
extension PSFormattableFloatingPoint {
    var defaultInternalFormatSpec: InternalFormatSpec {
        return InternalFormatSpec(align: ">", type: "\0")
    }
    /************************************************************************/
    /*********** float formatting *******************************************/
    /************************************************************************/
    func objectFormat(_ format: InternalFormatSpec) -> FormatResult {
        var val = self.formatableFloatingPoint
        
        var precision: Int = format.precision
        
        var default_precision = 6
        var type: Py_UCS4 = format.type
        var add_pct: Bool = false
        var spec: NumberFieldWidths
        var addDot:Bool = false
        var sign_char: Py_UCS4 = "\0"
        var unicode_tmp: String
        
        if type == "\0" {
            /* Omitted type specifier.  Behaves in the same way as repr(x)
             and str(x) if no precision is given, else like 'g', but with
             at least one digit after the decimal point. */
            addDot = true
            type = "r"
            default_precision = 0
        } else if type == "n" {
            /* 'n' is the same as 'g', except for the locale used to
             format the result. We take care of that later. */
            type = "g"
        } else if type == "%" {
            type = "f"
            val *= 100
            add_pct = true
        }
        
        if precision < 0 {
            precision = default_precision
        }
        else if type == "r" {
            type = "g"
        }
        
        /* Cast "type", because if we're in unicode we need to pass an
         8-bit char. This is safe, because we've restricted what "type"
         can be. */
        unicode_tmp = PyOS_double_to_string(val, type, precision, false, addDot, format.alternate)
        
        
        if add_pct {
            /* We know that buf has a trailing zero (since we just called
             strlen() on it), and we don't use that fact any more. So we
             can just write over the trailing zero. */
            unicode_tmp += "%"
        }
        
        if (format.sign != "+" && format.sign != " "
            && format.width == -1
            && format.type != "n"
            && format.thousands_separators == .LT_NO_LOCALE)
        {
            /* Fast path */
            return .success(unicode_tmp)
        }
        
        /* Is a sign character present in the output?  If so, remember it
         and skip it */
        if let c = unicode_tmp.first, c == "-" {
            sign_char = "-"
            unicode_tmp.removeFirst()
        }
        
        /* Determine the grouping, separator, and decimal point, if any. */
        /* Locale settings, either from the actual locale or
         from a hard-code pseudo-locale */
        let locale: LocaleInfo = get_locale_info(format.type == "n" ? .LT_CURRENT_LOCALE: format.thousands_separators)
        
        spec = calc_number_widths(sign_char, format)
        unicode_tmp = fill_number(spec, unicode_tmp, format, "", format.fill_char, locale, false)
        unicode_tmp = number_just(unicode_tmp, format, spec)
        return .success(unicode_tmp)
    }
}
protocol PSFormattableComplex: PSFormattable {
    var formatableReal: Double { get }
    var formatableImag: Double { get }
}
extension PSFormattableComplex {
    var defaultInternalFormatSpec: InternalFormatSpec {
        return InternalFormatSpec(align: ">", type: "\0")
    }
    /************************************************************************/
    /*********** complex formatting *****************************************/
    /************************************************************************/
    func objectFormat(_ format: InternalFormatSpec) -> FormatResult {
        let re = self.formatableReal
        let im = self.formatableImag
        
        var buf: String = ""
        
        var tmp_format: InternalFormatSpec = format
        var precision: int
        var default_precision = 6
        var type: Py_UCS4 = format.type
        var re_spec: NumberFieldWidths
        var im_spec: NumberFieldWidths
        var re_sign_char: Py_UCS4 = "\0"
        var im_sign_char: Py_UCS4 = "\0"
        var add_parens: Bool = false
        var skip_re: Bool = false
        var re_unicode_tmp: String
        var im_unicode_tmp: String
        
        precision = format.precision
        
        /* Zero padding is not allowed. */
        if (format.fill_char == "0") {
            return .failure(.valueError("Zero padding is not allowed in complex format specifier"))
        }
        
        /* Neither is '=' alignment . */
        if (format.align == "=") {
            return .failure(.valueError("'=' alignment flag is not allowed in complex format specifier"))
        }
        
        
        if (type == "\0") {
            /* Omitted type specifier. Should be like str(self). */
            type = "r"
            default_precision = 0
            if (re == 0.0 && copysign(1.0, re) == 1.0) {
                skip_re = true
            } else {
                add_parens = true
            }
        }
        
        if (type == "n") {
            /* 'n' is the same as 'g', except for the locale used to
             format the result. We take care of that later. */
            type = "g"
        }
        if (precision < 0) {
            precision = default_precision
        } else if (type == "r") {
            type = "g"
        }
        /* Cast "type", because if we're in unicode we need to pass an
         8-bit char. This is safe, because we've restricted what "type"
         can be. */
        re_unicode_tmp = PyOS_double_to_string(re, type, precision, false, false, format.alternate)
        im_unicode_tmp = PyOS_double_to_string(im, type, precision, false, false, format.alternate)
        
        
        /* Is a sign character present in the output?  If so, remember it
         and skip it */
        if (PyUnicode_READ_CHAR(re_unicode_tmp, 0) == "-") {
            re_sign_char = "-"
            re_unicode_tmp.removeFirst()
        }
        if (PyUnicode_READ_CHAR(im_unicode_tmp, 0) == "-") {
            im_sign_char = "-"
            im_unicode_tmp.removeFirst()
        }
        
        /* Determine the grouping, separator, and decimal point, if any. */
        /* Locale settings, either from the actual locale or
         from a hard-code pseudo-locale */
        let locale: LocaleInfo = get_locale_info(format.type == "n" ? .LT_CURRENT_LOCALE: format.thousands_separators)
        
        /* Turn off any padding. We'll do it later after we've composed
         the numbers without padding. */
        tmp_format.fill_char = "\0"
        tmp_format.align = "<"
        tmp_format.width = -1
        
        /* Calculate how much memory we'll need. */
        re_spec = calc_number_widths(re_sign_char, tmp_format)
        
        /* Same formatting, but always include a sign, unless the real part is
         * going to be omitted, in which case we use whatever sign convention was
         * requested by the original format. */
        if !skip_re {
            tmp_format.sign = "+"
        }
        im_spec = calc_number_widths(im_sign_char, tmp_format)
        
        re_unicode_tmp = number_just(re_unicode_tmp, tmp_format, re_spec)
        im_unicode_tmp = number_just(im_unicode_tmp, tmp_format, im_spec)
        
        if add_parens {
            buf = "(" + buf
        }
        
        if !skip_re {
            buf += fill_number(re_spec,
                               re_unicode_tmp,
                               tmp_format,
                               "",
                               "\0",
                               locale, false)
        }
        buf += fill_number(im_spec,
                           im_unicode_tmp,
                           tmp_format,
                           "", "\0",
                           locale, false)
        buf += "j"
        
        if add_parens {
            buf += ")"
        }
        return .success(fill_padding(buf, format.align, format.fill_char, format.width))
    }
}

/************************************************************************/
/*********** built in formatters ****************************************/
/************************************************************************/
func _PyUnicode_FormatAdvancedWriter(
    _ obj: PSFormattableString,
    _ format_spec: String) -> FormatResult
{
    var format: InternalFormatSpec
    
    /* check for the special case of zero length format spec, make
     it equivalent to str(obj) */
    if format_spec.isEmpty {
        return .success(obj.formattableString)
    }
    
    /* parse the format_spec */
    switch parse_internal_render_format_spec(format_spec, obj.defaultInternalFormatSpec) {
        case .success(let f):
            format = f
            break
        case .failure(let error):
            return .failure(error)
    }
    
    /* type conversion? */
    switch (format.type) {
        case "s":
            /* no type conversion needed, already a string.  do the formatting */
            return obj.objectFormat(format)
        default:
            /* unknown */
            return .failure(unknown_presentation_type(format.type, typeName(obj)))
    }
}

func _PyLong_FormatAdvancedWriter(
    _ obj: PSFormattableInteger,
    _ format_spec: String) -> FormatResult
{
    var format: InternalFormatSpec
    
    /* check for the special case of zero length format spec, make
     it equivalent to str(obj) */
    if format_spec.isEmpty {
        return .success(String(obj.formatableInteger))
    }
    
    /* parse the format_spec */
    switch parse_internal_render_format_spec(format_spec, obj.defaultInternalFormatSpec) {
        case .success(let f):
            format = f
            break
        case .failure(let error):
            return .failure(error)
    }
    
    /* type conversion? */
    switch (format.type) {
        case "b", "c", "d", "o", "x", "X", "n":
            /* no type conversion needed, already an int.  do the formatting */
            return obj.objectFormat(format)
            
        case "e", "E", "f", "F", "g", "G", "%":
            /* convert to float */
            return _PyFloat_FormatAdvancedWriter(Double(obj.formatableInteger), format_spec)
            
        default:
            /* unknown */
            return .failure(unknown_presentation_type(format.type, typeName(obj)))
    }
}

func _PyFloat_FormatAdvancedWriter(
    _ obj: PSFormattableFloatingPoint,
    _ format_spec: String) -> FormatResult
{
    var format: InternalFormatSpec
    
    /* check for the special case of zero length format spec, make
     it equivalent to str(obj) */
    if format_spec.isEmpty {
        return .success(.init(obj.formatableFloatingPoint))
    }
    /* parse the format_spec */
    switch parse_internal_render_format_spec(format_spec, obj.defaultInternalFormatSpec) {
        case .success(let f):
            format = f
            break
        case .failure(let error):
            return .failure(error)
    }
    
    /* type conversion? */
    switch (format.type) {
        case "\0", /* No format code: like 'g', but with at least one decimal. */
            "e", "E", "f", "F", "g", "G", "n", "%":
            /* no conversion, already a float.  do the formatting */
            return obj.objectFormat(format)
            
        default:
            /* unknown */
            return .failure(unknown_presentation_type(format.type, typeName(obj)))
    }
}

func _PyComplex_FormatAdvancedWriter(
    _ obj: PSFormattableComplex,
    _ format_spec: String) -> FormatResult
{
    var format: InternalFormatSpec
    
    /* parse the format_spec */
    switch parse_internal_render_format_spec(format_spec, obj.defaultInternalFormatSpec) {
        case .success(let f):
            format = f
        case .failure(let error):
            return .failure(error)
    }
    
    /* type conversion? */
    switch (format.type) {
        case "\0", /* No format code: like 'g', but with at least one decimal. */
            "e", "E", "f", "F", "g", "G", "n":
            /* no conversion, already a complex.  do the formatting */
            return obj.objectFormat(format)
            
        default:
            /* unknown */
            return .failure(unknown_presentation_type(format.type, typeName(obj)))
    }
}

func typeName(_ object: Any) -> String {
    return String(describing: type(of: object.self))
}

extension String {
    public var pythonFStringFields: [String] {
        let iter: MarkupIterator = .init(self, 0)
        var fields: [String] = []
        
    mark_up: while true {
        switch MarkupIterator_next(iter) {
            case .finish:
                break mark_up
            case .failure:
                break
            case .success(let item):
                if item.field_present {
                    fields.append(item.field_name)
                }
        }
    }
        
        return fields
    }
            
    public func format(_ args: Any..., kwargs: [String: Any] = [:]) throws -> String {
        try do_string_format(self, args, kwargs)
    }
    
    public func format_map(_ mapping: [String: Any]) throws -> String {
        try self.format(Array<Any>(), kwargs: mapping)
    }
}

extension Double: PSFormattableFloatingPoint {
    var formatableFloatingPoint: Double { return self }
}
extension Float: PSFormattableFloatingPoint {
    var formatableFloatingPoint: Double { return Double(self) }
}
extension Int: PSFormattableInteger {
    var formatableInteger: Int { return self }
}
extension Int8: PSFormattableInteger {
    var formatableInteger: Int { return Int(self) }
}
extension Int16: PSFormattableInteger {
    var formatableInteger: Int { return Int(self) }
}
extension Int32: PSFormattableInteger {
    var formatableInteger: Int { return Int(self) }
}
extension Int64: PSFormattableInteger {
    var formatableInteger: Int { return Int(self) }
}
extension UInt8: PSFormattableInteger {
    var formatableInteger: Int { return Int(self) }
}
extension UInt16: PSFormattableInteger {
    var formatableInteger: Int { return Int(self) }
}
extension UInt32: PSFormattableInteger {
    var formatableInteger: Int { return Int(self) }
}
extension UInt64: PSFormattableInteger {
    var formatableInteger: Int { return Int(self) }
}
