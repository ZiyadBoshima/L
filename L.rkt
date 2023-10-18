#lang racket
(require parser-tools/lex)
(require (prefix-in re: parser-tools/lex-sre))
(require parser-tools/cfg-parser)
(require net/url)
(require json)

; TOKENS
(define-tokens basic-tokens (NUM ID INT FLOAT STRING CHAR))
(define-empty-tokens punct-tokens (START END GETJOKE LCURLY RCURLY POINT ASSIGN EOF PRINT LPAREN RPAREN ADD SUB MUL DIV POW MOD LESS GREATER LEQUAL GEQUAL NEQUAL EQUAL OR AND NOT WALL CAST NLINE))

; Jokes API
(define url (string->url "https://official-joke-api.appspot.com/random_joke"))

; HASH-MAP TO DECLARE VARIABLES
(define my-hash (make-hash))

(define (set-variable! var-name value)
  (hash-set! my-hash (string->symbol var-name) value))

(define (get-variable var-name)
  (hash-ref my-hash (string->symbol var-name) #f))

; Lexer
(define LLexer
           (lexer
            ; Indicators
            ["start:" (token-START)]
            ["end start" (token-END)]
            ["{" (token-LCURLY)]
            ["}" (token-RCURLY)]
            ["(" (token-LPAREN)]
            [")" (token-RPAREN)]
            
            ; Print
            ["show" (token-PRINT)]
            ["|" (token-WALL)]
            [ "." (token-POINT)]
            [ "n" (token-NLINE)]
            
            ; Relational 
            ["[s]" (token-LESS)]
            ["[b]" (token-GREATER)]
            ["[se]" (token-LEQUAL)]
            ["[be]" (token-GEQUAL)]
            ["[ne]" (token-NEQUAL)]
            ["[e]" (token-EQUAL)]

            ; Logical
            ["[and]" (token-AND)]
            ["[not]" (token-NOT)]
            ["[or]" (token-OR)]
            
            ; Arithmetic
            ["[add]" (token-ADD)]
            ["[sub]" (token-SUB)]
            ["[mul]" (token-MUL)]
            ["[div]" (token-DIV)]
            ["[mod]" (token-MOD)]
            ["[pow]" (token-POW)]

            ;Other
            ["[mov]" (token-ASSIGN)]
            ["[tell me a joke]" (token-GETJOKE)]
            ["convert" (token-CAST)]
            [(eof) (token-EOF)]
            
            ; Combinations using Regular expressions

            ; Variables
            [(re:: alphabetic (re:*(re:or numeric alphabetic #\_)))(token-ID  lexeme)]

            ; Strings
            [(re:: "'" (re::(re:*(re:or numeric alphabetic (re:- symbolic "|") punctuation whitespace #\_)) "'"))(token-STRING  (substring lexeme 1 (- (string-length lexeme) 1)))]

            ; Characters
            [(re:: "-" (re:: alphabetic "-"))(token-CHAR  (string-ref lexeme 1))]

            ; Int
            [(re:: (re:or (re:: "-" numeric) numeric)(re:* numeric))(token-INT (string->number lexeme))]

            ; Float
            [(re::(re:: (re:or (re:: "-" numeric) numeric)(re:* numeric))(re::"."(re:+ numeric)))(token-FLOAT (string->number lexeme))]
                        
            ; Recursively calls the lexer which effectively skips whitespace
            (whitespace (LLexer input-port))
            ))
; Parser
(define LParser
           (cfg-parser
            ; First non-termnial
            (start program)
            ; Ends with EOF
            (end EOF)
            
            ; Error
            (error void)
            (tokens basic-tokens punct-tokens)
            
            ; GRAMMAR
            (grammar
             (program [[START stmt-list END] $2] )

             (stmt-list [[stmt stmt-list] $1]
                        [[stmt] $1])

             (stmt [[assign] $1]
                   [[print] $1]
                   [[cast] $1]
                   [[exp] $1]
                   [[ch-value] $1]
                   [[joke] $1])

             
             (assign [[ID values ASSIGN] (set-variable! $1 $2)]
                     [[ID LPAREN exp RPAREN ASSIGN] (set-variable! $1 $3)])

             (exp [[LPAREN exp RPAREN] $2]
                  [[arithmatic-exp] $1]
                  [[logical-exp] $1]
                  [[value] $1])


             ; VALUES    
             (values [[value] $1]
                     [[ch-value] $1])

             (value [[ID] (get-variable $1)]
                    [[INT] $1]
                    [[FLOAT] $1])
             
             (ch-value [[CHAR] $1]
                       [[STRING] $1])

             ; EXPRESSIONS
             (arithmatic-exp [[ value value ADD] (+ $1 $2)] ; add strings
                             [[ value value SUB] (- $1 $2)]
                             [[ value value MUL] (* $1 $2)]
                             [[ value value DIV] (/ $1 $2)]
                             [[ value value POW] (expt $1 $2)]
                             [[ value value MOD] (modulo  $1 $2)])
             
             (logical-exp [[logical-exp logical-exp AND] (and $1 $2)]
                          [[logical-exp logical-exp OR] (or $1 $2)] 
                          [[LPAREN logical-exp RPAREN NOT] (not $2)]
                          [[relational-exp] $1])
             
             (relational-exp [[value value LESS] (<  $1 $2)]
                             [[value value LEQUAL] ( <= $1 $2)]
                             [[value value GREATER] ( > $1 $2)]
                             [[value value GEQUAL] ( >= $1 $2)]
                             [[value value NEQUAL] (not (= $1 $2))]
                             [[value value EQUAL] ( = $1 $2)])

             ; CAST
             (cast [[CAST LPAREN values RPAREN] [cond [(integer? $3)(integer->char $3)]
                                                     [(char? $3)(char->integer $3)]
                                                     [else "error"]]])

             ; JOKE
             (joke [[GETJOKE] (printf "~a \n" (let ([x (read-json(get-pure-port url))]) (string-append (hash-ref x 'setup) (string-append "\n" (hash-ref x 'punchline)))))])

             
             ; PRINT
             (print [[PRINT LCURLY print-stmt RCURLY] [(lambda ()(printf "~a"   $3))]])
             
             (print-stmt [[print-stmt WALL print-value] (string-append $1 (toString $3))]
                         [[print-value] $1])
             
             (print-value [[exp] (toString $1)]
                          [[recursive-space] $1]
                          [[cast] $1]
                          [[ch-value] $1])
             
             (recursive-space [[POINT recursive-space] (string-append " " $2)]
                              [[POINT] " "]
                              [[NLINE] "\n"])

             )
            )
  )
  
(define (toString a) (cond [(number? a) (number->string a)]
                           [(symbol? a) (symbol->string a)]
                           [(string? a) a]
                           [(char? a) a]
                           [(boolean? a) (cond [(not a) "False"][else "True"])]))

(define (lex-this lexer input) (lambda () (lexer input)))


(let ((input (open-input-file "code.el")))
(LParser (lex-this LLexer input)))
(printf "\n")
