;;; tiny-vm.el --- A tiny 16-bit stack machine -*- lexical-binding: t; -*-

(require 'cl-lib)

(defconst tiny-vm-mask #xffff "Keep arithmetic within one machine word.")
(defvar tiny-vm-trace nil "Print each instruction when non-nil.")
(cl-defstruct tiny-vm (pc 0) stack)

(defun tiny-vm-run (program)
  "Execute bytecode PROGRAM and return the value at HALT."
  (let ((vm (make-tiny-vm)))
    (catch 'halt
      (while (< (tiny-vm-pc vm) (length program))
        (let ((instruction (aref program (tiny-vm-pc vm))))
          (when tiny-vm-trace
            (message "PC=%02x  %S" (tiny-vm-pc vm) instruction))
          (cl-incf (tiny-vm-pc vm))
          (pcase instruction
            (`(:push ,value)
             (push (logand value tiny-vm-mask) (tiny-vm-stack vm)))
            ('(:mul)
             ;; Pop two words, multiply, and wrap back to 16 bits.
             (unless (cdr (tiny-vm-stack vm)) (error "Stack underflow"))
             (let ((a (pop (tiny-vm-stack vm)))
                   (b (pop (tiny-vm-stack vm))))
               (push (logand (* a b) tiny-vm-mask) (tiny-vm-stack vm))))
            ('(:halt) (throw 'halt (car (tiny-vm-stack vm))))
            (_ (error "Unknown instruction: %S" instruction)))))
      (error "Program ended without HALT"))))

;; The answer to life, the universe, and everything.
(tiny-vm-run [(:push 6) (:push 7) (:mul) (:halt)]) ; => 42
