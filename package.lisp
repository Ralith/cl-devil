
(defpackage #:cl-devil
  (:nicknames #:il)
  (:use #:cl #:cffi :anaphora)
  (:shadow #:load #:error)
  (:export
   #:with-images
   ;; bindings
   #:BIND-IMAGE
   #:BLIT
   #:COPY-IMAGE
   #:COPY-PIXELS
   #:DELETE-IMAGES
   #:GEN-IMAGES
   #:GET-DATA
   #:GET-ERROR
   #:GET-INTEGER
   #:INIT
   #:LOAD
   #:LOAD-F
   #:LOAD-IMAGE
   #:LOAD-L
   #:OVERLAY-IMAGE
   #:SAVE
   #:SAVE-F
   #:SAVE-IMAGE
   #:SAVE-L
   #:SET-DATA
   #:SET-PIXELS
   #:SHUTDOWN
   #:TEX-IMAGE
   ))

(defpackage #:ilut
  (:use #:cl #:cffi)
  (:export
   #:CONVERT-TO-SDL-SURFACE
   #:DISABLE
   #:ENABLE
   #:GET-BOOLEAN
   #:GL-BIND-MIPMAPS
   #:GL-BIND-TEX-IMAGE
   #:GL-BUILD-MIPMAPS
   #:GL-LOAD-IMAGE
   #:GL-SAVE-IMAGE
   #:GL-SCREEN
   #:GL-SCREENIE
   #:GL-SET-TEX
   #:GL-SUB-TEX
   #:GL-TEX-IMAGE
   #:RENDERER
   #:SDL-SURFACE-FROM-BITMAP
   #:SDL-SURFACE-LOAD-IMAGE
   ))