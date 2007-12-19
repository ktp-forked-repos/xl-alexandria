(in-package :cl-user)

(eval-when (:compile-toplevel :load-toplevel)
  (require :sb-rt))

(require :alexandria)

(defpackage :alexandria-test
  (:use :cl :alexandria :sb-rt))

(in-package :alexandria-test)

;;;; Arrays

(deftest copy-array.1
    (let* ((orig (vector 1 2 3))
           (copy (copy-array orig)))
      (values (eq orig copy) (equalp orig copy)))
  nil t)

(deftest copy-array.2
    (let ((orig (make-array 1024 :fill-pointer 0)))
      (vector-push-extend 1 orig)
      (vector-push-extend 2 orig)
      (vector-push-extend 3 orig)
      (let ((copy (copy-array orig)))
        (values (eq orig copy) (equalp orig copy)
                (array-has-fill-pointer-p copy)
                (eql (fill-pointer orig) (fill-pointer copy)))))
  nil t t t)

(deftest array-index.1
    (typep 0 'array-index)
  t)

;;;; Control flow

(deftest switch.1
    (switch (13 :test =)
      (12 :oops)
      (13.0 :yay))
  :yay)

(deftest switch.2
    (switch (13)
      ((+ 12 2) :oops)
      ((- 13 1) :oops2)
      (t :yay))
  :yay)

(deftest eswitch.1
    (let ((x 13))
      (eswitch (x :test =)
        (12 :oops)
        (13.0 :yay)))
  :yay)

(deftest eswitch.2
    (let ((x 13))
      (eswitch (x :key 1+)
        (11 :oops)
        (14 :yay)))
  :yay)

(deftest cswitch.1
    (cswitch (13 :test =)
      (12 :oops)
      (13.0 :yay))
  :yay)

(deftest cswitch.2
    (cswitch (13 :key 1-)
      (12 :yay)
      (13.0 :oops))
  :yay)

(deftest whichever.1
    (let ((x (whichever 1 2 3)))
      (and (member x '(1 2 3)) t))
  t)

(deftest xor.1
    (xor nil nil 1 nil)
  1
  t)

;;;; Definitions

(deftest define-constant.1
    (let ((name (gensym)))
      (eval `(define-constant ,name "FOO" :test equal))
      (eval `(define-constant ,name "FOO" :test equal))
      (values (equal "FOO" (symbol-value name))
              (constantp name)))
  t
  t)

(deftest define-constant.2
    (let ((name (gensym)))
      (eval `(define-constant ,name 13))
      (eval `(define-constant ,name 13))
      (values (eql 13 (symbol-value name))
              (constantp name)))
  t
  t)

;;;; Errors

(deftest required-argument.1
    (multiple-value-bind (res err)
        (ignore-errors (required-argument))
      (typep err 'error))
  t)

;;;; Hash tables

(deftest ensure-hash-table.1
    (let ((table (make-hash-table))
          (x (list 1)))
      (multiple-value-bind (value already-there)
          (ensure-gethash x table 42)
        (and (= value 42)
             (not already-there)
             (= 42 (gethash x table))
             (multiple-value-bind (value2 already-there2)
                 (ensure-gethash x table 13)
               (and (= value2 42)
                    already-there2
                    (= 42 (gethash x table)))))))
  t)

(deftest copy-hash-table.1
    (let ((orig (make-hash-table :test 'eq :size 123))
          (foo "foo"))
      (setf (gethash orig orig) t
            (gethash foo orig) t)
      (let ((eq-copy (copy-hash-table orig))
            (eql-copy (copy-hash-table orig :test 'eql))
            (equal-copy (copy-hash-table orig :test 'equal))
            (equalp-copy (copy-hash-table orig :test 'equalp)))
        (list (hash-table-size eq-copy)
              (hash-table-count eql-copy)
              (gethash orig eq-copy)
              (gethash (copy-seq foo) eql-copy)
              (gethash foo eql-copy)
              (gethash (copy-seq foo) equal-copy)
              (gethash "FOO" equal-copy)
              (gethash "FOO" equalp-copy))))
  (123 2 t nil t t nil t))

(deftest maphash-keys.1
    (let ((keys nil)
          (table (make-hash-table)))
      (declare (notinline maphash-keys))
      (dotimes (i 10)
        (setf (gethash i table) t))
      (maphash-keys (lambda (k) (push k keys)) table)
      (set-equal keys '(0 1 2 3 4 5 6 7 8 9)))
  t)

(deftest maphash-values.1
    (let ((vals nil)
          (table (make-hash-table)))
      (declare (notinline maphash-values))
      (dotimes (i 10)
        (setf (gethash i table) (- i)))
      (maphash-values (lambda (v) (push v vals)) table)
      (set-equal vals '(0 -1 -2 -3 -4 -5 -6 -7 -8 -9)))
  t)

(deftest hash-table-keys.1
    (let ((table (make-hash-table)))
      (dotimes (i 10)
        (setf (gethash i table) t))
      (set-equal (hash-table-keys table) '(0 1 2 3 4 5 6 7 8 9)))
  t)

(deftest hash-table-values.1
    (let ((table (make-hash-table)))
      (dotimes (i 10)
        (setf (gethash (gensym) table) i))
      (set-equal (hash-table-values table) '(0 1 2 3 4 5 6 7 8 9)))
  t)

(deftest hash-table-alist.1
    (let ((table (make-hash-table)))
      (dotimes (i 10)
        (setf (gethash i table) (- i)))
      (let ((alist (hash-table-alist table)))
        (list (length alist)
              (assoc 0 alist)
              (assoc 3 alist)
              (assoc 9 alist)
              (assoc nil alist))))
  (10 (0 . 0) (3 . -3) (9 . -9) nil))

(deftest hash-table-plist.1
    (let ((table (make-hash-table)))
      (dotimes (i 10)
        (setf (gethash i table) (- i)))
      (let ((plist (hash-table-plist table)))
        (list (length plist)
              (getf plist 0)
              (getf plist 2)
              (getf plist 7)
              (getf plist nil))))
  (20 0 -2 -7 nil))

(deftest alist-hash-table.1
    (let* ((alist '((0 a) (1 b) (2 c)))
           (table (alist-hash-table alist)))
      (list (hash-table-count table)
            (gethash 0 table)
            (gethash 1 table)
            (gethash 2 table)
            (hash-table-test table)))
  (3 (a) (b) (c) eql))

(deftest plist-hash-table.1
    (let* ((plist '(:a 1 :b 2 :c 3))
           (table (plist-hash-table plist :test 'eq)))
      (list (hash-table-count table)
            (gethash :a table)
            (gethash :b table)
            (gethash :c table)
            (gethash 2 table)
            (gethash nil table)
            (hash-table-test table)))
  (3 1 2 3 nil nil eq))

;;;; Functions

(deftest disjoin.1
    (let ((disjunction (disjoin (lambda (x)
                                  (and (consp x) :cons))
                                (lambda (x)
                                  (and (stringp x) :string)))))
      (list (funcall disjunction 'zot)
            (funcall disjunction '(foo bar))
            (funcall disjunction "test")))
  (nil :cons :string))

(deftest conjoin.1
    (let ((conjunction (conjoin #'consp
                                (lambda (x)
                                  (stringp (car x)))
                                (lambda (x)
                                  (char (car x) 0)))))
      (list (funcall conjunction 'zot)
            (funcall conjunction '(foo))
            (funcall conjunction '("foo"))))
  (nil nil #\f))

(deftest compose.1
    (let ((composite (compose '1+
                              (lambda (x)
                                (* x 2))
                              #'read-from-string)))
      (funcall composite "1"))
  3)

(deftest compose.2
    (let ((composite
           (locally (declare (notinline compose))
             (compose '1+
                      (lambda (x)
                        (* x 2))
                      #'read-from-string))))
      (funcall composite "2"))
  5)

(deftest compose.3
    (let ((compose-form (funcall (compiler-macro-function 'compose)
                                 '(compose '1+
                                   (lambda (x)
                                     (* x 2))
                                   #'read-from-string)
                                 nil)))
      (let ((fun (funcall (compile nil `(lambda () ,compose-form)))))
        (funcall fun "3")))
  7)

(deftest multiple-value-compose.1
    (let ((composite (multiple-value-compose
                      #'truncate
                      (lambda (x y)
                        (values y x))
                      (lambda (x)
                        (with-input-from-string (s x)
                          (values (read s) (read s)))))))
      (multiple-value-list (funcall composite "2 7")))
  (3 1))

(deftest multiple-value-compose.2
    (let ((composite (locally (declare (notinline multiple-value-compose))
                       (multiple-value-compose
                        #'truncate
                        (lambda (x y)
                          (values y x))
                       (lambda (x)
                         (with-input-from-string (s x)
                           (values (read s) (read s))))))))
      (multiple-value-list (funcall composite "2 11")))
  (5 1))

(deftest multiple-value-compose.3
    (let ((compose-form (funcall (compiler-macro-function 'multiple-value-compose)
                                 '(multiple-value-compose
                                   #'truncate
                                   (lambda (x y)
                                     (values y x))
                                   (lambda (x)
                                     (with-input-from-string (s x)
                                       (values (read s) (read s)))))
                                 nil)))
      (let ((fun (funcall (compile nil `(lambda () ,compose-form)))))
        (multiple-value-list (funcall fun "2 9"))))
  (4 1))

(deftest curry.1
    (let ((curried (curry '+ 3)))
      (funcall curried 1 5))
  9)

(deftest curry.2
    (let ((curried (locally (declare (notinline curry))
                     (curry '* 2 3))))
      (funcall curried 7))
  42)

(deftest curry.3
    (let ((curried-form (funcall (compiler-macro-function 'curry)
                                 '(curry '/ 8)
                                 nil)))
      (let ((fun (funcall (compile nil `(lambda () ,curried-form)))))
        (funcall fun 2)))
  4)

(deftest rcurry.1
    (let ((r (rcurry '/ 2)))
      (funcall r 8))
  4)

(deftest named-lambda.1
    (let ((fac (named-lambda fac (x)
                 (if (> x 1)
                     (* x (fac (- x 1)))
                     x))))
      (funcall fac 5))
  120)

(deftest named-lambda.2
    (let ((fac (named-lambda fac (&key x)
                 (if (> x 1)
                     (* x (fac :x (- x 1)))
                     x))))
      (funcall fac :x 5))
  120)

;;;; Lists

(deftest alist-plist.1
    (alist-plist '((a . 1) (b . 2) (c . 3)))
  (a 1 b 2 c 3))

(deftest plist-alist.1
    (plist-alist '(a 1 b 2 c 3))
  ((a . 1) (b . 2) (c . 3)))

(deftest unionf.1
    (let* ((list (list 1 2 3))
           (orig list))
      (unionf list (list 1 2 4))
      (values (equal orig (list 1 2 3))
              (eql (length list) 4)
              (set-difference list (list 1 2 3 4))
              (set-difference (list 1 2 3 4) list)))
  t
  t
  nil
  nil)

(deftest nunionf.1
    (let ((list (list 1 2 3)))
      (nunionf list (list 1 2 4))
      (values (eql (length list) 4)
              (set-difference (list 1 2 3 4) list)
              (set-difference list (list 1 2 3 4))))
  t
  nil
  nil)

(deftest appendf.1
    (let* ((list (list 1 2 3))
           (orig list))
      (appendf list '(4 5 6) '(7 8))
      (list list (eq list orig)))
  ((1 2 3 4 5 6 7 8) nil))

(deftest nconcf.1
    (let ((list1 (list 1 2 3))
          (list2 (list 4 5 6)))
      (nconcf list1 list2 (list 7 8 9))
      list1)
  (1 2 3 4 5 6 7 8 9))

(deftest circular-list.1
    (let ((circle (circular-list 1 2 3)))
      (list (first circle)
            (second circle)
            (third circle)
            (fourth circle)
            (eq circle (nthcdr 3 circle))))
  (1 2 3 1 t))

(deftest circular-list-p.1
    (let* ((circle (circular-list 1 2 3 4))
           (tree (list circle circle))
           (dotted (cons circle t))
           (proper (list 1 2 3 circle))
           (tailcirc (list* 1 2 3 circle)))
      (list (circular-list-p circle)
            (circular-list-p tree)
            (circular-list-p dotted)
            (circular-list-p proper)
            (circular-list-p tailcirc)))
  (t nil nil nil t))

(deftest circular-list-p.2
    (circular-list-p 'foo)
  nil)

(deftest circular-tree-p.1
    (let* ((circle (circular-list 1 2 3 4))
           (tree1 (list circle circle))
           (tree2 (let* ((level2 (list 1 nil 2))
                         (level1 (list level2)))
                    (setf (second level2) level1)
                    level1))
           (dotted (cons circle t))
           (proper (list 1 2 3 circle))
           (tailcirc (list* 1 2 3 circle))
           (quite-proper (list 1 2 3))
           (quite-dotted (list 1 (cons 2 3))))
      (list (circular-tree-p circle)
            (circular-tree-p tree1)
            (circular-tree-p tree2)
            (circular-tree-p dotted)
            (circular-tree-p proper)
            (circular-tree-p tailcirc)
            (circular-tree-p quite-proper)
            (circular-tree-p quite-dotted)))
  (t t t t t t nil nil))

(deftest proper-list-p.1
    (let ((l1 (list 1))
          (l2 (list 1 2))
          (l3 (cons 1 2))
          (l4 (list (cons 1 2) 3))
          (l5 (circular-list 1 2)))
      (list (proper-list-p l1)
            (proper-list-p l2)
            (proper-list-p l3)
            (proper-list-p l4)
            (proper-list-p l5)))
  (t t nil t nil))

(deftest proper-list-p.2
    (proper-list-p '(1 2 . 3))
  nil)

(deftest proper-list.type.1
    (let ((l1 (list 1))
          (l2 (list 1 2))
          (l3 (cons 1 2))
          (l4 (list (cons 1 2) 3))
          (l5 (circular-list 1 2)))
      (list (typep l1 'proper-list)
            (typep l2 'proper-list)
            (typep l3 'proper-list)
            (typep l4 'proper-list)
            (typep l5 'proper-list)))
  (t t nil t nil))

(deftest lastcar.1
    (let ((l1 (list 1))
          (l2 (list 1 2)))
      (list (lastcar l1)
            (lastcar l2)))
  (1 2))

(deftest lastcar.error.2
    (handler-case
        (progn
          (lastcar (circular-list 1 2 3))
          nil)
      (error ()
        t))
  t)

(deftest setf-lastcar.1
    (let ((l (list 1 2 3 4)))
      (values (lastcar l)
              (progn
                (setf (lastcar l) 42)
                (lastcar l))))
  4
  42)

(deftest setf-lastcar.2
    (let ((l (circular-list 1 2 3)))
      (multiple-value-bind (res err)
          (ignore-errors (setf (lastcar l) 4))
        (typep err 'type-error)))
  t)

(deftest make-circular-list.1
    (let ((l (make-circular-list 3 :initial-element :x)))
      (setf (car l) :y)
      (list (eq l (nthcdr 3 l))
            (first l)
            (second l)
            (third l)
            (fourth l)))
  (t :y :x :x :y))

(deftest circular-list.type.1
    (let* ((l1 (list 1 2 3))
           (l2 (circular-list 1 2 3))
           (l3 (list* 1 2 3 l2)))
      (list (typep l1 'circular-list)
            (typep l2 'circular-list)
            (typep l3 'circular-list)))
  (nil t t))

(deftest ensure-list.1
    (let ((x (list 1))
          (y 2))
      (list (ensure-list x)
            (ensure-list y)))
  ((1) (2)))

(deftest ensure-cons.1
    (let ((x (cons 1 2))
          (y nil)
          (z "foo"))
      (values (ensure-cons x)
              (ensure-cons y)
              (ensure-cons z)))
  (1 . 2)
  (nil)
  ("foo"))

(deftest setp.1
    (setp '(1))
  t)

(deftest setp.2
    (setp nil)
  t)

(deftest setp.3
    (setp "foo")
  nil)

(deftest setp.4
    (setp '(1 2 3 1))
  nil)

(deftest setp.5
    (setp '(1 2 3))
  t)

(deftest setp.6
    (setp '(a :a))
  t)

(deftest setp.7
    (setp '(a :a) :key 'character)
  nil)

(deftest setp.8
    (setp '(a :a) :key 'character :test (constantly nil))
  t)

(deftest set-equal.1
    (set-equal '(1 2 3) '(3 1 2))
  t)

(deftest set-equal.2
    (set-equal '("Xa") '("Xb")
               :test (lambda (a b) (eql (char a 0) (char b 0))))
  t)

(deftest set-equal.3
    (set-equal '(1 2) '(4 2))
  nil)

(deftest set-equal.4
    (set-equal '(a b c) '(:a :b :c) :key 'string :test 'equal)
  t)

(deftest set-equal.5
    (set-equal '(a d c) '(:a :b :c) :key 'string :test 'equal)
  nil)

(deftest set-equal.6
    (set-equal '(a b c) '(a b c d))
  nil)

(deftest map-product.1
    (map-product 'cons '(2 3) '(1 4))
  ((2 . 1) (2 . 4) (3 . 1) (3 . 4)))

(deftest map-product.2
    (map-product #'cons '(2 3) '(1 4))
  ((2 . 1) (2 . 4) (3 . 1) (3 . 4)))

(deftest flatten.1
    (flatten '((1) 2 (((3 4))) ((((5)) 6)) 7))
  (1 2 3 4 5 6 7))

(deftest sans.1
    (let ((orig '(a 1 b 2 c 3 d 4)))
      (list (sans orig 'a 'c)
            (sans orig 'b 'd)
            (sans orig 'b)
            (sans orig 'a)
            (sans orig 'd 42 "zot")
            (sans orig 'a 'b 'c 'd)
            (sans orig 'a 'b 'c 'd 'x)
            (equal orig '(a 1 b 2 c 3 d 4))))
  ((b 2 d 4)
   (a 1 c 3)
   (a 1 c 3 d 4)
   (b 2 c 3 d 4)
   (a 1 b 2 c 3)
   nil
   nil
   t))

(deftest mappend.1
    (mappend (compose 'list '*) '(1 2 3) '(1 2 3))
  (1 4 9))

;;;; Numbers

(deftest clamp.1
    (list (clamp 1.5 1 2)
          (clamp 2.0 1 2)
          (clamp 1.0 1 2)
          (clamp 3 1 2)
          (clamp 0 1 2))
  (1.5 2.0 1.0 2 1))

(deftest gaussian-random.1
    (let ((min -0.2)
          (max +0.2))
      (multiple-value-bind (g1 g2)
          (gaussian-random min max)
        (values (<= min g1 max)
                (<= min g2 max)
                (/= g1 g2) ;uh
                )))
  t
  t
  t)

(deftest iota.1
    (iota 3)
  (0 1 2))

(deftest iota.2
    (iota 3 :start 0.0d0)
  (0.0d0 1.0d0 2.0d0))

(deftest iota.3
    (iota 3 :start 2 :step 3.0)
  (2.0 5.0 8.0))

(deftest map-iota.1
    (let (all)
      (declare (notinline map-iota))
      (values (map-iota (lambda (x) (push x all))
                        3
                        :start 2
                        :step 1.1d0)
              all))
  3
  (4.2d0 3.1d0 2.0d0))

(deftest lerp.1
    (lerp 0.5 1 2)
  1.5)

(deftest lerp.2
    (lerp 0.1 1 2)
  1.1)

(deftest mean.1
    (mean '(1 2 3))
  2)

(deftest mean.2
    (mean '(1 2 3 4))
  5/2)

(deftest mean.3
    (mean '(1 2 10))
  13/3)

(deftest median.1
    (median '(100 0 99 1 98 2 97))
  97)

(deftest median.2
    (median '(100 0 99 1 98 2 97 96))
  195/2)

(deftest variance.1
    (variance (list 1 2 3))
  2/3)

(deftest standard-deviation.1
    (< 0 (standard-deviation (list 1 2 3)) 1)
  t)

(deftest maxf.1
    (let ((x 1))
      (maxf x 2)
      x)
  2)

(deftest maxf.2
    (let ((x 1))
      (maxf x 0)
      x)
  1)

(deftest maxf.3
    (let ((x 1)
          (c 0))
      (maxf x (incf c))
      (list x c))
  (1 1))

(deftest maxf.4
    (let ((xv (vector 0 0 0))
          (p 0))
      (maxf (svref xv (incf p)) (incf p))
      (list p xv))
  (2 #(0 2 0)))

(deftest minf.1
    (let ((y 1))
      (minf y 0)
      y)
  0)

(deftest minf.2
    (let ((xv (vector 10 10 10))
          (p 0))
      (minf (svref xv (incf p)) (incf p))
      (list p xv))
  (2 #(10 2 10)))

;;;; Arrays

#+nil
(deftest array-index.type)

#+nil
(deftest copy-array)

;;;; Sequences

(deftest rotate.1
    (list (rotate (list 1 2 3) 0)
          (rotate (list 1 2 3) 1)
          (rotate (list 1 2 3) 2)
          (rotate (list 1 2 3) 3)
          (rotate (list 1 2 3) 4))
  ((1 2 3)
   (3 1 2)
   (2 3 1)
   (1 2 3)
   (3 1 2)))

(deftest rotate.2
    (list (rotate (vector 1 2 3 4) 0)
          (rotate (vector 1 2 3 4))
          (rotate (vector 1 2 3 4) 2)
          (rotate (vector 1 2 3 4) 3)
          (rotate (vector 1 2 3 4) 4)
          (rotate (vector 1 2 3 4) 5))
  (#(1 2 3 4)
    #(4 1 2 3)
    #(3 4 1 2)
    #(2 3 4 1)
    #(1 2 3 4)
    #(4 1 2 3)))

(deftest rotate.3
    (list (rotate (list 1 2 3) 0)
          (rotate (list 1 2 3) -1)
          (rotate (list 1 2 3) -2)
          (rotate (list 1 2 3) -3)
          (rotate (list 1 2 3) -4))
  ((1 2 3)
   (2 3 1)
   (3 1 2)
   (1 2 3)
   (2 3 1)))

(deftest rotate.4
    (list (rotate (vector 1 2 3 4) 0)
          (rotate (vector 1 2 3 4) -1)
          (rotate (vector 1 2 3 4) -2)
          (rotate (vector 1 2 3 4) -3)
          (rotate (vector 1 2 3 4) -4)
          (rotate (vector 1 2 3 4) -5))
  (#(1 2 3 4)
   #(2 3 4 1)
   #(3 4 1 2)
   #(4 1 2 3)
   #(1 2 3 4)
   #(2 3 4 1)))

(deftest rotate.5
    (values (rotate (list 1) 17)
            (rotate (list 1) -5))
  (1)
  (1))

(deftest shuffle.1
    (let ((s (shuffle (iota 100))))
      (list (equal s (iota 100))
            (every (lambda (x)
                     (member x s))
                   (iota 100))
            (every (lambda (x)
                     (typep x '(integer 0 99)))
                   s)))
  (nil t t))

(deftest shuffle.2
    (let ((s (shuffle (coerce (iota 100) 'vector))))
      (list (equal s (coerce (iota 100) 'vector))
            (every (lambda (x)
                     (find x s))
                   (iota 100))
            (every (lambda (x)
                     (typep x '(integer 0 99)))
                   s)))
  (nil t t))

(deftest random-elt.1
    (let ((s1 #(1 2 3 4))
          (s2 '(1 2 3 4)))
      (list (dotimes (i 1000 nil)
              (unless (member (random-elt s1) s2)
                (return nil))
              (when (/= (random-elt s1) (random-elt s1))
                (return t)))
            (dotimes (i 1000 nil)
              (unless (member (random-elt s2) s2)
                (return nil))
              (when (/= (random-elt s2) (random-elt s2))
                (return t)))))
  (t t))

(deftest removef.1
    (let* ((x '(1 2 3))
           (x* x)
           (y #(1 2 3))
           (y* y))
      (removef x 1)
      (removef y 3)
      (list x x* y y*))
  ((2 3)
   (1 2 3)
   #(1 2)
   #(1 2 3)))

(deftest deletef.1
    (let* ((x '(1 2 3))
           (x* x)
           (y (vector 1 2 3)))
      (deletef x 2)
      (deletef y 1)
      (list x x* y))
  ((1 3)
   (1 3)
   #(2 3)))

(deftest proper-sequence.type.1
    (mapcar (lambda (x)
              (typep x 'proper-sequence))
            (list (list 1 2 3)
                  (vector 1 2 3)
                  #2a((1 2) (3 4))
                  (circular-list 1 2 3 4)))
  (t t nil nil))

(deftest emptyp.1
    (mapcar #'emptyp
            (list (list 1)
                  (circular-list 1)
                  nil
                  (vector)
                  (vector 1)))
  (nil nil t t nil))

(deftest sequence-of-length-p.1
    (mapcar #'sequence-of-length-p
            (list nil
                  #()
                  (list 1)
                  (vector 1)
                  (list 1 2)
                  (vector 1 2)
                  (list 1 2)
                  (vector 1 2)
                  (list 1 2)
                  (vector 1 2))
            (list 0
                  0
                  1
                  1
                  2
                  2
                  1
                  1
                  4
                  4))
  (t t t t t t nil nil nil nil))

(deftest copy-sequence.1
    (let ((l (list 1 2 3))
          (v (vector #\a #\b #\c)))
      (declare (notinline copy-sequence))
      (let ((l.list (copy-sequence 'list l))
            (l.vector (copy-sequence 'vector l))
            (l.spec-v (copy-sequence '(vector fixnum) l))
            (v.vector (copy-sequence 'vector v))
            (v.list (copy-sequence 'list v))
            (v.string (copy-sequence 'string v)))
        (list (member l (list l.list l.vector l.spec-v))
              (member v (list v.vector v.list v.string))
              (equal l.list l)
              (equalp l.vector #(1 2 3))
              (eq 'fixnum (array-element-type l.spec-v))
              (equalp v.vector v)
              (equal v.list '(#\a #\b #\c))
              (equal "abc" v.string))))
  (nil nil t t t t t t))

(deftest first-elt.1
    (mapcar #'first-elt
            (list (list 1 2 3)
                  "abc"
                  (vector :a :b :c)))
  (1 #\a :a))

(deftest first-elt.error.1
    (mapcar (lambda (x)
              (handler-case
                  (first-elt x)
                (type-error ()
                  :type-error)))
            (list nil
                  #()
                  12
                  :zot))
  (:type-error
   :type-error
   :type-error
   :type-error))

(deftest setf-first-elt.1
    (let ((l (list 1 2 3))
          (s (copy-seq "foobar"))
          (v (vector :a :b :c)))
      (setf (first-elt l) -1
            (first-elt s) #\x
            (first-elt v) 'zot)
      (values l s v))
  (-1 2 3)
  "xoobar"
  #(zot :b :c))

(deftest setf-first-elt.error.1
    (let ((l 'foo))
      (multiple-value-bind (res err)
          (ignore-errors (setf (first-elt l) 4))
        (typep err 'type-error)))
  t)

(deftest last-elt.1
    (mapcar #'last-elt
            (list (list 1 2 3)
                  (vector :a :b :c)
                  "FOOBAR"
                  #*001
                  #*010))
  (3 :c #\R 1 0))

(deftest last-elt.error.1
    (mapcar (lambda (x)
              (handler-case
                  (last-elt x)
                (type-error ()
                  :type-error)))
            (list nil
                  #()
                  12
                  :zot
                  (circular-list 1 2 3)
                  (list* 1 2 3 (circular-list 4 5))))
  (:type-error
   :type-error
   :type-error
   :type-error
   :type-error
   :type-error))

(deftest setf-last-elt.1
    (let ((l (list 1 2 3))
          (s (copy-seq "foobar"))
          (b (copy-seq #*010101001)))
      (setf (last-elt l) '???
            (last-elt s) #\?
            (last-elt b) 0)
      (values l s b))
  (1 2 ???)
  "fooba?"
  #*010101000)

(deftest setf-last-elt.error.1
    (handler-case
        (setf (last-elt 'foo) 13)
      (type-error ()
        :type-error))
  :type-error)

(deftest starts-with.1
    (list (starts-with 1 '(1 2 3))
          (starts-with 1 #(1 2 3))
          (starts-with #\x "xyz")
          (starts-with 2 '(1 2 3))
          (starts-with 3 #(1 2 3))
          (starts-with 1 1)
          (starts-with nil nil))
  (t t t nil nil nil nil))

(deftest starts-with.2
    (values (starts-with 1 '(-1 2 3) :key '-)
            (starts-with "foo" '("foo" "bar") :test 'equal)
            (starts-with "f" '(#\f) :key 'string :test 'equal)
            (starts-with -1 '(0 1 2) :key #'1+)
            (starts-with "zot" '("ZOT") :test 'equal))
  t
  t
  t
  nil
  nil)

(deftest ends-with.1
    (list (ends-with 3 '(1 2 3))
          (ends-with 3 #(1 2 3))
          (ends-with #\z "xyz")
          (ends-with 2 '(1 2 3))
          (ends-with 1 #(1 2 3))
          (ends-with 1 1)
          (ends-with nil nil))
  (t t t nil nil nil nil))

(deftest ends-with.2
    (values (ends-with 2 '(0 13 1) :key '1+)
            (ends-with "foo" (vector "bar" "foo") :test 'equal)
            (ends-with "X" (vector 1 2 #\X) :key 'string :test 'equal)
            (ends-with "foo" "foo" :test 'equal))
  t
  t
  t
  nil)

(deftest ends-with.error.1
    (handler-case
        (ends-with 3 (circular-list 3 3 3 1 3 3))
      (type-error ()
        :type-error))
  :type-error)

(deftest with-unique-names.1
    (let ((*gensym-counter* 0))
      (let ((syms (with-unique-names (foo bar quux)
                    (list foo bar quux))))
        (list (find-if #'symbol-package syms)
              (equal '("FOO0" "BAR1" "QUUX2")
                     (mapcar #'symbol-name syms)))))
  (nil t))

(deftest with-unique-names.2
    (let ((*gensym-counter* 0))
      (let ((syms (with-unique-names ((foo "_foo_") (bar -bar-) (quux #\q))
                    (list foo bar quux))))
        (list (find-if #'symbol-package syms)
              (equal '("_foo_0" "-BAR-1" "q2")
                     (mapcar #'symbol-name syms)))))
  (nil t))

(deftest with-unique-names.3
    (let ((*gensym-counter* 0))
      (multiple-value-bind (res err)
          (ignore-errors
            (eval
             '(let ((syms
                     (with-unique-names ((foo "_foo_") (bar -bar-) (quux 42))
                       (list foo bar quux))))
               (list (find-if #'symbol-package syms)
                (equal '("_foo_0" "-BAR-1" "q2")
                 (mapcar #'symbol-name syms))))))
        (typep err 'error)))
  t)

(deftest once-only.1
    (macrolet ((cons1.good (x)
                 (once-only (x)
                   `(cons ,x ,x)))
               (cons1.bad (x)
                 `(cons ,x ,x)))
      (let ((y 0))
        (list (cons1.good (incf y))
              y
              (cons1.bad (incf y))
              y)))
  ((1 . 1) 1 (2 . 3) 3))

(deftest parse-body.1
    (parse-body '("doc" "body") :documentation t)
  ("body")
  nil
  "doc")

(deftest parse-body.2
    (parse-body '("body") :documentation t)
  ("body")
  nil
  nil)

(deftest parse-body.3
    (parse-body '("doc" "body"))
  ("doc" "body")
  nil
  nil)

(deftest parse-body.4
    (parse-body '((declare (foo)) "doc" (declare (bar)) body) :documentation t)
  (body)
  ((declare (foo)) (declare (bar)))
  "doc")

(deftest parse-body.5
    (parse-body '((declare (foo)) "doc" (declare (bar)) body))
  ("doc" (declare (bar)) body)
  ((declare (foo)))
  nil)

(deftest parse-body.6
    (multiple-value-bind (res err)
        (ignore-errors
          (parse-body '("foo" "bar" "quux")
                      :documentation t))
      (typep err 'error))
  t)

;;;; Symbols

(deftest ensure-symbol.1
    (ensure-symbol :cons :cl)
  cons
  :external)

(deftest ensure-symbol.2
    (ensure-symbol "CONS" :alexandria)
  cons
  :inherited)

(deftest ensure-symbol.3
    (ensure-symbol 'foo :keyword)
  :foo
  :external)

(deftest ensure-symbol.4
    (ensure-symbol #\* :alexandria)
  *
  :inherited)

(deftest format-symbol.1
    (let ((s (format-symbol nil "X-~D" 13)))
      (list (symbol-package s)
            (symbol-name s)))
  (nil "X-13"))

(deftest format-symbol.2
    (format-symbol :keyword "SYM-~A" :bolic)
  :sym-bolic)

(deftest format-symbol.3
    (let ((*package* (find-package :cl)))
      (format-symbol t "FIND-~A" 'package))
  find-package)

(deftest make-keyword.1
    (list (make-keyword 'zot)
          (make-keyword "FOO")
          (make-keyword #\Q))
  (:zot :foo :q))

(deftest make-gensym-list.1
    (let ((*gensym-counter* 0))
      (let ((syms (make-gensym-list 3 "FOO")))
        (list (find-if 'symbol-package syms)
              (equal '("FOO0" "FOO1" "FOO2")
                     (mapcar 'symbol-name syms)))))
  (nil t))

;;;; Type-system

(deftest of-type.1
    (locally
        (declare (notinline of-type))
    (let ((f (of-type 'string)))
      (list (funcall f "foo")
            (funcall f 'bar))))
  (t nil))

(deftest type=.1
    (type= 'string 'string)
  t
  t)

(deftest type=.2
    (type= 'list '(or null cons))
  t
  t)

(deftest type=.3
    (type= 'null '(and symbol list))
  t
  t)

(deftest type=.4
    (type= 'string '(satisfies emptyp))
  nil
  nil)

(deftest type=.5
    (type= 'string 'list)
  nil
  t)

;;;; Bindings

(declaim (notinline opaque))
(defun opaque (x)
  x)

(deftest if-let.1
    (if-let (x (opaque :ok))
            x
            :bad)
  :ok)

(deftest if-let.2
    (if-let (x (opaque nil))
            :bad
            (and (not x) :ok))
  :ok)

(deftest if-let.3
    (let ((x 1))
      (if-let ((x 2)
               (y x))
              (+ x y)
              :oops))
  3)

(deftest if-let.4
    (if-let ((x 1)
             (y nil))
            :oops
            (and (not y) x))
  1)

(deftest if-let.5
    (if-let (x)
            :oops
            (not x))
  t)

(deftest if-let.error.1
    (handler-case
        (eval '(if-let x
                :oops
                :oops))
      (type-error ()
        :type-error))
  :type-error)

(deftest if-let*.1
    (let ((x 1))
      (if-let* ((x 2)
                (y x))
               (+ x y)
               :oops))
  4)

(deftest if-let*.2
    (if-let* ((x 2)
              (y (prog1 x (setf x nil))))
             :oops
             (and (not x) y))
  2)

(deftest if-let*.3
    (if-let* (x 1)
             x
             :oops)
  1)

(deftest if-let*.error.1
    (handler-case
        (eval '(if-let* x :oops :oops))
      (type-error ()
        :type-error))
  :type-error)

(deftest when-let.1
    (when-let (x (opaque :ok))
      (setf x (cons x x))
      x)
  (:ok . :ok))

(deftest when-let.2
    (when-let ((x 1)
               (y nil)
               (z 3))
      :oops)
  nil)

(deftest when-let.3
    (let ((x 1))
      (when-let ((x 2)
                 (y x))
        (+ x y)))
  3)

(deftest when-let.error.1
    (handler-case
        (eval '(when-let x :oops))
      (type-error ()
        :type-error))
  :type-error)

(deftest when-let*.1
    (let ((x 1))
      (when-let* ((x 2)
                  (y x))
        (+ x y)))
  4)

(deftest when-let*.2
    (let ((y 1))
      (when-let* (x y)
        (1+ x)))
  2)

(deftest when-let*.error.1
    (handler-case
        (eval '(when-let* x :oops))
      (type-error ()
        :type-error))
  :type-error)
