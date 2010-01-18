;;;; cl-devil -- DevIL binding for CL.  See README for licensing information.

(in-package :il)

(define-foreign-library il
  (:unix (:or "libIL" "libIL.so.1"))
  (:windows "DevIL.dll")
  (t (:default "libIL")))
(use-foreign-library il)

(defctype handle :pointer)
(defcenum image-type
  (:unknown #x0000)
  (:bmp #x0420)
  (:cut #x0421)
  (:doom #x0422)
  (:doom-flat #x0423)
  (:ico #x0424)
  (:jpg #x0425)
  (:jfif #x0425)
  (:lbm #x0426)
  (:pcd #x0427)
  (:pcx #x0428)
  (:pic #x0429)
  (:png #x042A)
  (:pnm #x042B)
  (:sgi #x042C)
  (:tga #x042D)
  (:tif #x042E)
  (:chead #x042F)
  (:raw #x0430)
  (:mdl #x0431)
  (:wal #x0432)
  (:lif #x0434)
  (:mng #x0435)
  (:jng #x0435)
  (:gif #x0436)
  (:dds #x0437)
  (:dcx #x0438)
  (:psd #x0439)
  (:exif #x043A)
  (:psp #x043B)
  (:pix #x043C)
  (:pxr #x043D)
  (:xpm #x043E)
  (:hdr #x043F)
  (:jasc-pal #x0475))

(defcenum data-format
  (:colour-index #x1900)
  (:color-index #x1900)
  (:rgb #x1907)
  (:rgba #x1908)
  (:bgr #x80E0)
  (:bgra #x80E1)
  (:luminance #x1909)
  (:luminance-alpha #x190A))

(defcenum data-type
  (:byte #x1400)
  (:unsigned-byte #x1401)
  (:short #x1402)
  (:unsigned-short #x1403)
  (:int #x1404)
  (:unsigned-int #x1405)
  (:float #x1406)
  (:double #x140A))

(define-condition devil-error (cl:error)
  ((enum-value :initarg :enum-value :reader enum-value)))
(macrolet ((deferrs (&rest keys)
             `(progn
                (defcenum error ,@keys)
                ,@(loop for (key value) in keys collecting
                       (let ((symbol (intern (symbol-name key))))
                         `(define-condition ,symbol (devil-error) ()
                            (:default-initargs :enum-value ,key)))))))
  (deferrs
    (:no-error #x0000)
    (:invalid-enum #x0501)
    (:out-of-memory #x0502)
    (:format-not-supported #x0503)
    (:internal-error #x0504)
    (:invalid-value #x0505)
    (:illegal-operation #x0506)
    (:illegal-file-value #x0507)
    (:invalid-file-header #x0508)
    (:invalid-param #x0509)
    (:could-not-open-file #x050A)
    (:invalid-extension #x050B)
    (:file-already-exists #x050C)
    (:out-format-same #x050D)
    (:stack-overflow #x050E)
    (:stack-underflow #x050F)
    (:invalid-conversion #x0510)
    (:bad-dimensions #x0511)
    (:file-read-error #x0512)
    (:file-write-error #x0512)
    (:lib-gif-error #x05E1)
    (:lib-jpeg-error #x05E2)
    (:lib-png-error #x05E3)
    (:lib-tiff-error #x05E4)
    (:lib-mng-error #x05E5)
    (:unknown-error #x05FF)))

(defcenum mode
  (:file-overwrite #x0620)
  (:file-mode #x0621)
  (:conv-pal #x0630)
  (:use-key-color #x0635)
  (:png-alpha-index #x0724)
  (:version-num #x0DE2)
  (:image-width #x0DE4)
  (:image-height #x0DE5)
  (:image-depth #x0DE6)
  (:image-size-of-data #x0DE7)
  (:image-bpp #x0DE8)
  (:image-bytes-per-pixel #x0DE8)
  (:image-bits-per-pixel #x0DE9)
  (:image-format #x0DEA)
  (:image-type #x0DEB)
  (:palette-type #x0DEC)
  (:palette-size #x0DED)
  (:palette-bpp #x0DEE)
  (:palette-num-cols #x0DEF)
  (:palette-base-type #x0DF0)
  (:num-images #x0DF1)
  (:num-mipmaps #x0DF2)
  (:num-layers #x0DF3)
  (:active-image #x0DF4)
  (:active-mipmap #x0DF5)
  (:active-layer #x0DF6)
  (:cur-image #x0DF7)
  (:image-duration #x0DF8)
  (:image-planesize #x0DF9)
  (:image-bpc #x0DFA)
  (:image-offx #x0DFB)
  (:image-offy #x0DFC)
  (:image-cubeflags #x0DFD)
  (:image-origin #x0DFE)
  (:image-channels #x0DFF))

(define-foreign-type pathname-string-type ()
  ()
  (:actual-type :string)
  (:simple-parser pathname-string))
(eval-when (:compile-toplevel :load-toplevel)
  (defmethod expand-to-foreign-dyn (value var body (type pathname-string-type))
    `(with-foreign-string (,var (if (pathnamep ,value) (namestring ,value) ,value))
       ,@body)))

(defmacro maybe-error (call)
  `(if ,call
       (values)
       (cl:error (make-condition (find-symbol (symbol-name (get-error)) (find-package :il))))))

(defmacro deferrwrap (name &optional args)
  `(defun ,name ,args
     (maybe-error (,(symbolicate "%" (symbol-name name)) ,@args))))

(defcfun ("ilInit" init) :void)
(defcfun ("ilShutDown" shutdown) :void)
(defcfun ("ilGenImages" %gen-images) :void (num :int) (images :pointer))
(defun gen-images (count)
  (with-foreign-object (texture-array :uint count)
    (%gen-images count texture-array)
    (loop for i below count
       collect (mem-aref texture-array :uint i))))
(defun gen-image ()
  (car (gen-images 1)))

(defcfun ("ilBindImage" bind-image) :void (image :int))
(defcfun ("ilDeleteImages" %delete-images) :void (num :int) (images :pointer))
(defun delete-images (images)
  (with-foreign-object (array :uint (length images))
    (loop for i below (length images)
       for image in images
       do (setf (mem-aref array :uint i) image))
    (%delete-images (length images) array)))

(defcfun ("ilLoadImage" %load-image) :boolean (file-name pathname-string))
(deferrwrap load-image (file-name))
(defcfun ("ilLoad" %load) :boolean (type image-type) (file-name pathname-string))
(deferrwrap load (type file-name))
(defcfun ("ilLoadF" %load-f) :boolean (type image-type) (file handle))
(deferrwrap load-f (type handle))
(defcfun ("ilLoadL" %load-l) :boolean (type image-type) (lump :pointer) (size :uint))
(deferrwrap load-l (type pointer size))

(defcfun ("ilSaveImage" %save-image) :boolean (file-name pathname-string))
(deferrwrap save-image (file-name))
(defcfun ("ilSave" %save) :boolean (type image-type) (file-name pathname-string))
(deferrwrap save (type file-name))
(defcfun ("ilSaveF" %save-f) :boolean (type image-type) (file handle))
(deferrwrap save-f (type handle))
(defcfun ("ilSaveL" %save-l) :boolean (type image-type) (lump :pointer) (size :uint))
(deferrwrap save-l (type pointer size))

(defcfun ("ilTexImage" %tex-image) :boolean
  (width :uint) (height :uint) (depth :uint) (bpp :uint8) (format data-format) (type data-type) (data :pointer))
(deferrwrap tex-image (width height depth bpp format type data))
(defcfun ("ilGetData" get-data) :pointer)
(defcfun ("ilCopyPixels" copy-pixels) :uint
  (x-offset :uint) (y-offset :uint) (z-offset :uint) (width :uint) (height :uint) (depth :uint) (format data-format) (type data-type) (data :pointer))
(defcfun ("ilSetData" set-data) :pointer)
(defcfun ("ilSetPixels" set-pixels) :uint
  (x-offset :uint) (y-offset :uint) (z-offset :uint) (width :uint) (height :uint) (depth :uint) (format data-format) (type data-type) (data :pointer))
(defcfun ("ilCopyImage" %copy-image) :boolean (source :uint))
(deferrwrap copy-image (source))
(defcfun ("ilOverlayImage" %overlay-image) :boolean (source :uint) (x-coord :int) (y-coord :int) (z-coord :int))
(deferrwrap overlay-image (source x y z))
(defcfun ("ilBlit" %blit) :boolean (source :uint) (dest-x :int) (dest-y :int) (dest-z :int) (src-x :int) (src-y :int) (src-z :int) (width :uint) (height :uint) (depth :uint))
(deferrwrap blit (source dest-x dest-y dest-z src-x src-y src-z width height depth))
(defcfun ("ilGetError" get-error) error)

(defcfun ("ilKeyColour" key-color) :void (red :float) (green :float) (blue :float) (alpha :float))
(defcfun ("ilGetPalette" get-palette) :pointer)

(defcfun ("ilGetInteger" get-integer) :uint (mode mode))
(defcfun ("ilSetInteger" set-integer) :void (mode mode) (param :int))
(defcfun ("ilEnable" %enable) :boolean (mode mode))
(deferrwrap enable (mode))
(defcfun ("ilDisable" %disable) :boolean (mode mode))
(deferrwrap disable (mode))
(defcfun ("ilIsEnabled" %is-enabled) :boolean (mode mode))
(defun enabledp (mode)
  (%is-enabled mode))

(defcfun ("ilConvertImage" %convert-image) :boolean (format data-format) (type data-type))
(deferrwrap convert-image (format type))
#-win32
(progn
  (defcfun ("ilFlipImage" %flip-image) :boolean)
  (deferrwrap flip-image))

(defcfun ("ilDetermineType" determine-type) image-type (pathname pathname-string))