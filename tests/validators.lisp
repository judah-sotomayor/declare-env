(fiasco:define-test-package #:declare-env-tests.validators
  (:use #:declare-env.validators))
(in-package :declare-env-tests.validators)

(deftest port-inside-range ()
  (is (= 1 (validate-port "1")))
  (is (= 65535 (validate-port "65535")))
  (is (= 8080 (validate-port "8080")))
  (is (= 443 (validate-port "443"))))

(deftest port-outside-range ()
  (signals validation-error (validate-port "0"))
  (signals validation-error (validate-port "65536"))
  (signals validation-error (validate-port "-1"))
  (signals validation-error (validate-port "2000000")))

(deftest port-junk-data ()
  (signals validation-error (validate-port "abc"))
  (signals validation-error (validate-port "8080abc"))
  (signals validation-error (validate-port "dj443"))
  (signals validation-error (validate-port "dj443asdf")))

