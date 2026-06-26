(fiasco:define-test-package #:declare-env-tests
  (:documentation "Tests for the declare-env system.")
  (:export
   #:run-tests))

(in-package :declare-env-tests)

(defun run-declare-env-tests ()
  (run-package-tests
   :packages '(:declare-env-tests
               :declare-env-tests.validators)
   :interactive t))

