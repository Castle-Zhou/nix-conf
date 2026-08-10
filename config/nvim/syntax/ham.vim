if exists("b:current_syntax")
  finish
endif

" ─── Comments ──────────────────────────────────────────────────────────────

" Documentation comments (JSDoc-style /** ... */)
syn region  hamDocComment    start="/\*\*" end="\*/" keepend
                           \ contains=hamDocTag
syn match   hamDocTag       contained "@[A-Za-z_]\+"
" Block comments /* ... */
syn region  hamComment       start="/\*"   end="\*/" keepend contains=NONE
" Single-line comments
syn region  hamLineComment   start="//" end="$" contains=NONE

" ─── String Literals ───────────────────────────────────────────────────────

syn region  hamString        start=+"+  skip=+\\\\\|\\"+  end=+"+

" ─── Numbers (integer & float) ─────────────────────────────────────────────

syn match   hamNumber        "\<[0-9]\+\%([eE][+-]\?[0-9]\+\)\?"
syn match   hamNumber        "\<[0-9]\+\.[0-9]*\%([eE][+-]\?[0-9]\+\)\?"
syn match   hamNumber        "\<\.[0-9]\+\%([eE][+-]\?[0-9]\+\)\?"
" Hex / binary / octal (future-proof)
syn match   hamNumber        "\<0[xX][0-9a-fA-F]\+\>"
syn match   hamNumber        "\<0[bB][01]\+\>"
syn match   hamNumber        "\<0[oO][0-7]\+\>"

" ─── Boolean & Null ────────────────────────────────────────────────────────

syn keyword hamBoolean       true false
syn keyword hamNull          null

" ─── Keywords ──────────────────────────────────────────────────────────────

syn keyword hamConditional   if else
syn keyword hamOperator      or
syn keyword hamInclude       import
syn keyword hamStorageClass  linear

" ─── Built-in Type / Collection Identifiers ───────────────────────────────

syn keyword hamType          Int Int8 Int16 Int32 Int64 Int128
syn keyword hamType          Float Float16 Float32 Float64 Float128
syn keyword hamType          Bool Char Char8 Char16 Char32
syn keyword hamType          String Real Number Null
syn keyword hamType          Nothing Something Anything Any Sth

" ─── Variadic Markers (.... and ...) ───────────────────────────────────────

syn match   hamVariadic      "\.\.\.\."
syn match   hamVariadic      "\.\.\."

" ─── Special Identifiers (#-prefixed locals) ──────────────────────────────

syn match   hamLocalId       "#[A-Za-z_][A-Za-z0-9_]*"

" ─── Function Calls (identifier before opening paren) ────────────────────────
" Uses \ze zero-width lookahead so only the name is highlighted, not the '('.
" Keywords (if, import, etc.) defined via syn keyword take priority over matches,
" so they keep their keyword highlighting even when followed by '('.
syn match   hamFunction      "\<[A-Za-z_][A-Za-z0-9_]*\ze("
syn match   hamFunction      "#[A-Za-z_][A-Za-z0-9_]*\ze("

" ─── Operators & Special Symbols ──────────────────────────────────────────

" Δ operator (delta) — composition merge / value merge
syn match   hamDeltaOp       "<|"
" Recursive binding (allows self-reference in definition)
syn match   hamRecursiveBind "<-"
" Function arrow
syn match   hamArrow         "=>"
" Type arrow (in type expressions like Int->String)
syn match   hamTypeArrow     "->"
" Set union operator
syn match   hamSetUnion      "|"

" General operators
syn match   hamOperator      "=="
syn match   hamOperator      "!="
syn match   hamOperator      "<="
syn match   hamOperator      ">="
syn match   hamOperator      "&&"
syn match   hamOperator      "||"
syn match   hamOperator      "[+\-%&|~^<>]"
syn match   hamOperator      "/[/*]\@!"
syn match   hamOperator      "\*\*/\@!"
syn match   hamOperator      "[<>=!]"

" ─── Delimiters (braces, parens, brackets, access, comma) ─────────────────

syn match   hamBraces        "[{}]"
syn match   hamParens        "[()]"
syn match   hamBrackets      "[\[\]]"
syn match   hamDelimiter     "\."
syn match   hamDelimiter     ","

" ─── Type Annotation (key:Type or param:Type) ─────────────────────────────
" Captures :TypeName patterns including higher-kinded types.
" Examples:
"   x:Int = 1
"   f:Int->Int = x:Int => x + 1
"   comb:{ x:Int, y:Int }
"   x:Int | Float
syn match   hamTypeAnnot
  \ ":[ \t]*[A-Za-z_][A-Za-z0-9_]*\%(\s*[|]\s*[A-Za-z_][A-Za-z0-9_]*\)*\%(\s*->\s*[A-Za-z_][A-Za-z0-9_]*\)*"

" ─── Lines Not to Be Syntax-Expanded ──────────────────────────────────────

" ─── Highlight Links (color assignments) ──────────────────────────────────

hi def link hamDocComment     Comment
hi def link hamDocTag         SpecialComment
hi def link hamComment        Comment
hi def link hamLineComment    Comment
hi def link hamString         String
hi def link hamNumber         Number
hi def link hamBoolean        Boolean
hi def link hamNull           Constant
hi def link hamConditional    Conditional
hi def link hamOperator       Operator
hi def link hamInclude        Include
hi def link hamStorageClass   StorageClass
hi def link hamType           Type
hi def link hamVariadic       Special
hi def link hamFunction       Function
hi def link hamDeltaOp        Special
hi def link hamRecursiveBind  Special
hi def link hamArrow          Special
hi def link hamTypeArrow      Type
hi def link hamSetUnion       Operator
hi def link hamBraces         Delimiter
hi def link hamParens         Delimiter
hi def link hamBrackets       Delimiter
hi def link hamDelimiter      Delimiter
hi def link hamTypeAnnot      Type

let b:current_syntax = "ham"
