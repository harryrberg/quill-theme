;;; perceptron.el --- Learn a simple AND gate -*- lexical-binding: t; -*-

(require 'cl-lib)

(defun perceptron-predict (weights inputs)
  "Classify INPUTS using WEIGHTS, with the bias stored first."
  (let ((score (+ (car weights)
                  (cl-reduce #'+ (cl-mapcar #'* (cdr weights) inputs)))))
    (if (>= score 0) 1 0)))

(defun perceptron-train (samples epochs rate)
  "Learn from SAMPLES for EPOCHS passes at learning RATE."
  (let ((weights (make-list (1+ (length (caar samples))) 0.0)))
    (dotimes (_epoch epochs weights)
      (dolist (sample samples)
        (pcase-let* ((`(,inputs ,target) sample)
                     (error (- target (perceptron-predict weights inputs))))
          ;; Adjust the bias and every input weight together.
          (setq weights
                (cl-mapcar (lambda (weight input)
                             (+ weight (* rate error input)))
                           weights (cons 1 inputs))))))))

(let* ((samples '(((0 0) 0) ((0 1) 0) ((1 0) 0) ((1 1) 1)))
       (weights (perceptron-train samples 20 0.1)))
  (mapcar (lambda (sample)
            (perceptron-predict weights (car sample)))
          samples))
;; => (0 0 0 1)
