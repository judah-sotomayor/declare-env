(fiasco:define-test-package #:declare-env-tests.validators
  (:use #:declare-env.validators))
(in-package :declare-env-tests.validators)


(deftest validate-port-inside-range ()
  (is (= 1 (validate-port "1")))
  (is (= 65535 (validate-port "65535")))
  (is (= 8080 (validate-port "8080")))
  (is (= 443 (validate-port "443"))))

(deftest validate-port-outside-range ()
  (signals validation-error (validate-port "0"))
  (signals validation-error (validate-port "65536"))
  (signals validation-error (validate-port "-1"))
  (signals validation-error (validate-port "2000000")))

(deftest validate-port-junk-data ()
  (signals validation-error (validate-port "abc"))
  (signals validation-error (validate-port "8080abc"))
  (signals validation-error (validate-port "dj443"))
  (signals validation-error (validate-port "dj443asdf")))



(deftest validate-bool-true ()
  (is (validate-boolean "yes"))
  (is (validate-boolean "1"))
  (is (validate-boolean "True"))
  (is (validate-boolean "true"))
  (is (validate-boolean "yES")))

(deftest validate-bool-false ()
  (not (validate-boolean "no"))
  (not (validate-boolean "0"))
  (not (validate-boolean "false"))
  (not (validate-boolean "NO"))
  (not (validate-boolean "")))

(deftest validate-bool-junk-data ()
  (signals validation-error (validate-boolean "1234"))
  (signals validation-error (validate-boolean "-1"))
  (signals validation-error (validate-boolean "hello boyos"))
  (signals validation-error (validate-boolean "BAD"))
  (signals validation-error (validate-boolean "ehhh")))
