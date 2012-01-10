; -*- mode: lisp; package: user; encoding: shift_jis -*-

(in-package :user)

(require "xl-alexandria/arrays")
(require "xl-alexandria/binding")
(require "xl-alexandria/conditions")
(require "xl-alexandria/control-flow")
(require "xl-alexandria/definitions")
(require "xl-alexandria/features")
(require "xl-alexandria/functions")
(require "xl-alexandria/hash-tables")
(require "xl-alexandria/io")
(require "xl-alexandria/lists")
(require "xl-alexandria/macros")
(require "xl-alexandria/numbers")
(require "xl-alexandria/sequences")
(require "xl-alexandria/strings")
(require "xl-alexandria/symbols")
(require "xl-alexandria/types")

(require "xl-alexandria/indent-hook")
(require "xl-alexandria/version")


(defun use-alexandria (&key (package *package*)
                            (shadowing-import-from :lisp))
  "copy-file �� featurep �� shadow ���Ȃ��� alexandria �� use-package ����B
copy-file �� featurep �� lisp �p�b�P�[�W�̂��̂� shadowing-import �����B"
  (shadow (intern "copy-file" :lisp) package)
  (shadow (intern "featurep" :lisp) package)
  (use-package :alexandria package)
  (shadowing-import (intern "copy-file" shadowing-import-from) package)
  (shadowing-import (intern "featurep" shadowing-import-from)) package)


(provide "xl-alexandria")

;;; End