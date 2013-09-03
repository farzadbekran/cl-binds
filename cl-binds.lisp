;;;; cl-binds.lisp

(in-package #:cl-binds)

(defclass bindable-object (attributes-object)
  ((%bound-object :accessor %bound-object :initarg :%bound-object :initform nil))
  (:metaclass attributes-class)
  (:documentation "if %bound-object is non nil, every slot that provides a
:bound-slot will read/write it's value from/to the slot of %bound-object.
you can specify the name of the slot direcly in the :bound-slot attribute
or in this format: (:name 'foo :reader 'bar :writer 'baz). this allows you
to get a hook when there is a data being written/read to/from this slot when
it's bound."))

(defmethod closer-mop:slot-value-using-class :around ((class attributes-class) (object bindable-object) (slotd attributed-effective-slot))
  (let* ((slot-name (closer-mop:slot-definition-name slotd)) ;the name of the slot we are setting
	 (bound-slot (slot-attrib object slot-name :bound-slot))) ;the name of the slot that is supposed to be changed on the bound object
    (cond ((and bound-slot (%bound-object object)) ;if the object is bound to another object and the slot is bound as well
	   (cond ((listp bound-slot) ;if bound-slot is a list, it might have a reader function
		  (let ((reader-func (or (getf bound-slot :reader) #'identity))
			(bound-slot-name (getf bound-slot :name)))
		    (cond (reader-func
			   (funcall reader-func (slot-value (%bound-object object) bound-slot-name)))
			  (t 
			   (slot-value (%bound-object object) bound-slot-name)))))
		 (t ;it's not a list so we expect simply a slot name without reader/writer functions
		  (slot-value (%bound-object object) bound-slot))))
	  (t ;it's not currently bound to any object, usual behaviour
	   (call-next-method)))))

(defmethod (setf closer-mop:slot-value-using-class) :around (new-value (class attributes-class) (object bindable-object) (slotd attributed-effective-slot))
  (cond ((slot-boundp object '%all-attributes) ;make sure it's bound
	 (let* ((slot-name (closer-mop:slot-definition-name slotd))
		(bound-slot (slot-attrib object slot-name :bound-slot)))
	   (cond ((and bound-slot (%bound-object object)) ;if the object is bound to another object and the slot is bound as well
		  (cond ((listp bound-slot) ;if bound-slot is a list, it might have a writer function
			 (let ((writer-func (or (getf bound-slot :writer) #'identity))
			       (bound-slot-name (getf bound-slot :name)))
			   (setf (slot-value (%bound-object object) bound-slot-name)
				 (funcall writer-func new-value))))
			(t ;it has no writer function defined, just set the new value
			 (setf (slot-value (%bound-object object) bound-slot) new-value))))))))
  (call-next-method))

;;this is just to make sure there is no binding during the init phase, to prevent bound object from getting messed up!
(defmethod initialize-instance :around ((object bindable-object) &rest initargs)
  (let ((bound-object (getf initargs :%bound-object))
	(new-args (concatenate 'list `(:%bound-object nil) initargs)))
    (let ((result (apply #'call-next-method `(,object ,@new-args))))
      (setf (%bound-object result) bound-object)
      result)))
