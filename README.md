## xl-alexandria - A collection of portable public domain utilities for xyzzy Lisp

* Home URL: <http://miyamuko.s56.xrea.com/xyzzy/xl-alexandria/intro.htm>
* Version: 0.0.1


### SYNOPSIS

```lisp
(require "alexandria")
;=> t

(alexandria:flatten '((1 2 3) 4 ((((5))))))
;=> (1 2 3 4 5)

(alexandria:plist-alist '(:foo 1 :bar 2))
;=> ((:foo . 1) (:bar . 2))

(alexandria:iota 5)
;=> (0 1 2 3 4)

(alexandria:when-let (buf (find-buffer "*test*"))
  (delete-buffer buf))
;=> t (*test* というバッファがある場合)
```


### DESCRIPTION

xl-alexandria は Common Lisp の [Alexandria](http://common-lisp.net/project/alexandria/)
を xyzzy に移植したものです。

Alexandria は巨大なユーティリティ集です。
実践 Common Lisp や OnLisp に載っていたり、自分で書いたことがあるような
関数・マクロが大量に詰まっています。


### INSTALL

1. [NetInstaller](http://www7a.biglobe.ne.jp/~hat/xyzzy/ni.html)
   で xl-alexandria, ansi-loop, ansify, setf-values をインストールします。

2. xl-alexandria はライブラリであるため自動的にロードはされません。
   必要な時点で require してください。


### REFERENCE

パッケージ名は alexandria.0.dev です。ニックネーム alexandria です。

詳細は [Alexandria のリファレンス](http://common-lisp.net/project/alexandria/draft/alexandria.html)
を参照してください。

alexandria パッケージには lisp パッケージと同名のシンボルがあります (copy-file と featurep)。

そのまま use するとシンボルが衝突するので、必要なパッケージの方のシンボルを shadowing-import してください。

```lisp
(eval-when (:compile-toplevel :load-toplevel :execute)
  (unless (find-package :your-cool-application)
    (require "alexandria")

    (defpackage :your-cool-application
      (:use :lisp :alexandria)
      (:shadowing-import-from :lisp
       ;; 以下のシンボルが alexandria と衝突するので lisp パッケージの方をインポート
       :copy-file
       :featurep
       )
      )))
```

また、scratch バッファで使いたい場合などは use-alexandria という便利関数を利用できます。

```lisp
(require "alexandria")
;=> nil

(use-alexandria)
;=> #<package: user>

(mapcar (compose #'make-keyword #'package-name #'symbol-package)
        '(copy-file featurep))
;=> (:lisp :lisp)


;; alexandria の copy-file と featurep を使いたい場合はこうする。

(use-alexandria :shadowing-import-from :alexandria)
;=> #<package: user>

(mapcar (compose #'make-keyword #'package-name #'symbol-package)
        '(copy-file featurep))
;=> (:alexandria.0.dev :alexandria.0.dev)
```


### TODO

なし。


### KNOWN BUGS

* xyzzy の subtypep がバグっているので、type= が正しく動作しない

  ```lisp
  (alexandria:type= 'null '(and symbol list))
  ;=> nil (本当は t)
  ;   t
  ```

要望やバグは
[GitHub Issues](http://github.com/miyamuko/xl-winhttp/issues) か
[@miyamuko](http://twitter.com/home?status=%40miyamuko%20%23xyzzy%20xl-winhttp%3a%20)
まで。


### AUTHOR

みやむこ かつゆき (<mailto:miyamuko@gmail.com>)


### COPYRIGHT

xl-alexandria はパブリックドメイン（または MIT ライセンス）です。

    xl-alexandria software and associated documentation are in the public
    domain:

      Authors dedicate this work to public domain, for the benefit of the
      public at large and to the detriment of the authors' heirs and
      successors. Authors intends this dedication to be an overt act of
      relinquishment in perpetuity of all present and future rights under
      copyright law, whether vested or contingent, in the work. Authors
      understands that such relinquishment of all rights includes the
      relinquishment of all rights to enforce (by lawsuit or otherwise)
      those copyrights in the work.

      Authors recognize that, once placed in the public domain, the work
      may be freely reproduced, distributed, transmitted, used, modified,
      built upon, or otherwise exploited by anyone for any purpose,
      commercial or non-commercial, and in any way, including by methods
      that have not yet been invented or conceived.

    In those legislations where public domain dedications are not
    recognized or possible, xl-alexandria is distributed under the following
    terms and conditions:

      Permission is hereby granted, free of charge, to any person
      obtaining a copy of this software and associated documentation files
      (the "Software"), to deal in the Software without restriction,
      including without limitation the rights to use, copy, modify, merge,
      publish, distribute, sublicense, and/or sell copies of the Software,
      and to permit persons to whom the Software is furnished to do so,
      subject to the following conditions:

      THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
      EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
      MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
      IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
      CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
      TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
      SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
