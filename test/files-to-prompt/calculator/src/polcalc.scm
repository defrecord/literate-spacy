;; [[file:../.workspace/20250320_171642/calculator.org::*/Users/jasonwalsh/projects/defrecord/literate-spacy/test/files-to-prompt/calculator/src/polcalc.scm][/Users/jasonwalsh/projects/defrecord/literate-spacy/test/files-to-prompt/calculator/src/polcalc.scm:1]]
;; [[file:../../../../../../../../../var/folders/9z/9bvmr7bs731_0ps9m4yhb3380000gn/T/tmp.zVm7sfJiQh/calculator.org::*/Users/jasonwalsh/projects/defrecord/literate-spacy/test/files-to-prompt/calculator/src/polcalc.scm][/Users/jasonwalsh/projects/defrecord/literate-spacy/test/files-to-prompt/calculator/src/polcalc.scm:1]]
#!/usr/bin/env scheme-script
;; Polish Notation Calculator
;; A simple calculator that accepts expressions in prefix (Polish) notation

(define (string->number-safe str)
  "Convert string to number safely, returning #f if not a number"
  (with-exception-handler
    (lambda (exn) #f)
    (lambda () (string->number str))))

(define (tokenize expr)
  "Split expression into tokens"
  (string-split expr char-whitespace?))

(define (calculate tokens)
  "Evaluate a list of tokens in Polish notation"
  (let loop ((tokens tokens)
             (stack '()))
    (cond
      ;; No more tokens and one result on stack
      ((and (null? tokens) (= (length stack) 1))
       (car stack))
      
      ;; No more tokens but incorrect number of values on stack
      ((null? tokens)
       (error "Invalid expression: too many or too few operands"))
      
      (else
        (let ((token (car tokens))
              (rest (cdr tokens)))
          
          ;; Check if token is an operator
          (case token
            ;; Addition
            (("+")
             (if (< (length stack) 2)
                 (error "Not enough operands for +")
                 (let ((b (cadr stack))
                       (a (car stack)))
                   (loop rest (cons (+ a b) (cddr stack))))))
            
            ;; Subtraction
            (("-")
             (if (< (length stack) 2)
                 (error "Not enough operands for -")
                 (let ((b (cadr stack))
                       (a (car stack)))
                   (loop rest (cons (- a b) (cddr stack))))))
            
            ;; Multiplication
            (("*")
             (if (< (length stack) 2)
                 (error "Not enough operands for *")
                 (let ((b (cadr stack))
                       (a (car stack)))
                   (loop rest (cons (* a b) (cddr stack))))))
            
            ;; Division
            (("/")
             (if (< (length stack) 2)
                 (error "Not enough operands for /")
                 (let ((b (cadr stack))
                       (a (car stack)))
                   (if (zero? a)
                       (error "Division by zero")
                       (loop rest (cons (/ a b) (cddr stack)))))))
            
            ;; If token is not an operator, try to parse as number
            (else
              (let ((num (string->number-safe token)))
                (if num
                    (loop rest (cons num stack))
                    (error (string-append "Unknown token: " token)))))))))))

(define (evaluate expr)
  "Evaluate a Polish notation expression"
  (calculate (reverse (tokenize expr))))

;; Command-line interface
(define (main args)
  (if (null? args)
      (begin
        (display "Usage: polcalc.scm \"EXPRESSION\"\n")
        (display "Example: polcalc.scm \"+ 2 3\"\n")
        (exit 1))
      (let ((result (evaluate (car args))))
        (display result)
        (newline))))

;; Run main function with command-line arguments
(main (cdr (command-line)))
;; /Users/jasonwalsh/projects/defrecord/literate-spacy/test/files-to-prompt/calculator/src/polcalc.scm:1 ends here
;; /Users/jasonwalsh/projects/defrecord/literate-spacy/test/files-to-prompt/calculator/src/polcalc.scm:1 ends here
