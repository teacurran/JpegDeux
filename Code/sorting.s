.text
	.align 2
	.globl _sortNumber
_sortNumber:
	mflr r5
	stmw r24,-32(r1)
	bcl 20,31,L1$pb
L1$pb:
	stw r5,8(r1)
	mflr r31
	stwu r1,-112(r1)
	addis r2,r31,ha16(L_OBJC_SELECTOR_REFERENCES_4-L1$pb)
	mr r27,r4
	lwz r28,lo16(L_OBJC_SELECTOR_REFERENCES_4-L1$pb)(r2)
	li r26,0
	li r24,0
	li r25,0
	mr r4,r28
	bl L_objc_msgSend$stub
	mr r4,r28
	mr r30,r3
	mr r3,r27
	bl L_objc_msgSend$stub
	addis r2,r31,ha16(L_OBJC_SELECTOR_REFERENCES_6-L1$pb)
	mr r28,r3
	lwz r29,lo16(L_OBJC_SELECTOR_REFERENCES_6-L1$pb)(r2)
	mr r3,r30
	mr r4,r29
	bl L_objc_msgSend$stub
	mr r4,r29
	mr r27,r3
	mr r3,r28
	bl L_objc_msgSend$stub
	cmpwi cr0,r27,0
	mr r29,r3
	bne+ cr0,L2
	addis r9,r31,ha16(L_OBJC_SELECTOR_REFERENCES_7-L1$pb)
	addis r8,r31,ha16(L_OBJC_CLASS_REFERENCES_1-L1$pb)
	lwz r4,lo16(L_OBJC_SELECTOR_REFERENCES_7-L1$pb)(r9)
	lwz r3,lo16(L_OBJC_CLASS_REFERENCES_1-L1$pb)(r8)
	bl L_objc_msgSend$stub
	addis r7,r31,ha16(L_OBJC_SELECTOR_REFERENCES_8-L1$pb)
	lwz r4,lo16(L_OBJC_SELECTOR_REFERENCES_8-L1$pb)(r7)
	bl L_objc_msgSend$stub
	mr r4,r30
	addis r6,r31,ha16(L_OBJC_SELECTOR_REFERENCES_9-L1$pb)
	mr r26,r3
	lwz r5,lo16(L_OBJC_SELECTOR_REFERENCES_9-L1$pb)(r6)
	addi r3,r1,64
	mr r6,r26
	bl L_objc_msgSend_stret$stub
	lwz r5,64(r1)
	lis r4,0x7fff
	ori r3,r4,65535
	cmpw cr0,r5,r3
	beq- cr0,L4
	addis r10,r31,ha16(L_OBJC_SELECTOR_REFERENCES_10-L1$pb)
	mr r3,r30
	lwz r4,lo16(L_OBJC_SELECTOR_REFERENCES_10-L1$pb)(r10)
	bl L_objc_msgSend$stub
	cmplwi cr0,r3,255
	bgt- cr0,L5
	addis r5,r31,ha16(L__DefaultRuneLocale$non_lazy_ptr-L1$pb)
	slwi r0,r3,2
	lwz r2,lo16(L__DefaultRuneLocale$non_lazy_ptr-L1$pb)(r5)
	add r12,r0,r2
	lwz r11,52(r12)
	rlwinm r0,r11,22,31,31
	b L7
L5:
	li r0,0
L7:
	cmpwi cr0,r0,0
	bne- cr0,L2
L4:
	li r24,1
L2:
	cmpwi cr0,r29,0
	bne- cr0,L8
	cmpwi cr0,r26,0
	bne+ cr0,L9
	addis r3,r31,ha16(L_OBJC_SELECTOR_REFERENCES_7-L1$pb)
	addis r6,r31,ha16(L_OBJC_CLASS_REFERENCES_1-L1$pb)
	lwz r4,lo16(L_OBJC_SELECTOR_REFERENCES_7-L1$pb)(r3)
	lwz r3,lo16(L_OBJC_CLASS_REFERENCES_1-L1$pb)(r6)
	bl L_objc_msgSend$stub
	addis r26,r31,ha16(L_OBJC_SELECTOR_REFERENCES_8-L1$pb)
	lwz r4,lo16(L_OBJC_SELECTOR_REFERENCES_8-L1$pb)(r26)
	bl L_objc_msgSend$stub
	mr r26,r3
L9:
	addis r8,r31,ha16(L_OBJC_SELECTOR_REFERENCES_9-L1$pb)
	mr r4,r28
	lwz r5,lo16(L_OBJC_SELECTOR_REFERENCES_9-L1$pb)(r8)
	mr r6,r26
	addi r3,r1,64
	bl L_objc_msgSend_stret$stub
	lwz r5,64(r1)
	lis r7,0x7fff
	ori r4,r7,65535
	cmpw cr0,r5,r4
	beq- cr0,L11
	addis r9,r31,ha16(L_OBJC_SELECTOR_REFERENCES_10-L1$pb)
	mr r3,r28
	lwz r4,lo16(L_OBJC_SELECTOR_REFERENCES_10-L1$pb)(r9)
	bl L_objc_msgSend$stub
	cmplwi cr0,r3,255
	bgt- cr0,L12
	addis r5,r31,ha16(L__DefaultRuneLocale$non_lazy_ptr-L1$pb)
	slwi r0,r3,2
	lwz r2,lo16(L__DefaultRuneLocale$non_lazy_ptr-L1$pb)(r5)
	add r12,r0,r2
	lwz r10,52(r12)
	rlwinm r0,r10,22,31,31
	b L14
L12:
	li r0,0
L14:
	cmpwi cr0,r0,0
	bne- cr0,L8
L11:
	li r25,1
L8:
	cmpwi cr7,r24,0
	beq- cr7,L17
	cmpwi cr0,r25,0
	beq+ cr0,L15
	addis r24,r31,ha16(L_OBJC_SELECTOR_REFERENCES_11-L1$pb)
	mr r3,r30
	lwz r4,lo16(L_OBJC_SELECTOR_REFERENCES_11-L1$pb)(r24)
	mr r5,r28
	bl L_objc_msgSend$stub
	b L1
L15:
	beq- cr7,L17
	li r3,1
	b L1
L17:
	cmpwi cr0,r25,0
	li r3,-1
	bne- cr0,L1
	cmpw cr0,r27,r29
	li r3,1
	bgt- cr0,L1
	cmpw cr0,r29,r27
	li r3,-1
	bgt- cr0,L1
	li r3,0
L1:
	lwz r25,120(r1)
	addi r1,r1,112
	mtlr r25
	lmw r24,-32(r1)
	blr
.data
.objc_cat_cls_meth
.data
.objc_cat_inst_meth
.data
.objc_string_object
.data
.section __OBJC, __cstring_object
.data
.objc_message_refs
.data
.section __OBJC, __sel_fixup
.data
.objc_cls_refs
.data
.objc_class
.data
.objc_meta_class
.data
.objc_cls_meth
.data
.objc_inst_meth
.data
.objc_protocol
.data
.objc_class_names
.data
.objc_meth_var_types
.data
.objc_meth_var_names
.data
.objc_category
.data
.objc_class_vars
.data
.objc_instance_vars
.data
.objc_module_info
.data
.objc_symbols
.data
.objc_symbols
	.align 2
L_OBJC_SYMBOLS:
	.long	0
	.long	0
	.short	0
	.short	0
.data
.objc_message_refs
	.align 2
L_OBJC_SELECTOR_REFERENCES_0:
	.long	L_OBJC_METH_VAR_NAME_0
	.align 2
L_OBJC_SELECTOR_REFERENCES_1:
	.long	L_OBJC_METH_VAR_NAME_1
	.align 2
L_OBJC_SELECTOR_REFERENCES_2:
	.long	L_OBJC_METH_VAR_NAME_2
	.align 2
L_OBJC_SELECTOR_REFERENCES_3:
	.long	L_OBJC_METH_VAR_NAME_3
	.align 2
L_OBJC_SELECTOR_REFERENCES_4:
	.long	L_OBJC_METH_VAR_NAME_4
	.align 2
L_OBJC_SELECTOR_REFERENCES_5:
	.long	L_OBJC_METH_VAR_NAME_5
	.align 2
L_OBJC_SELECTOR_REFERENCES_6:
	.long	L_OBJC_METH_VAR_NAME_6
	.align 2
L_OBJC_SELECTOR_REFERENCES_7:
	.long	L_OBJC_METH_VAR_NAME_7
	.align 2
L_OBJC_SELECTOR_REFERENCES_8:
	.long	L_OBJC_METH_VAR_NAME_8
	.align 2
L_OBJC_SELECTOR_REFERENCES_9:
	.long	L_OBJC_METH_VAR_NAME_9
	.align 2
L_OBJC_SELECTOR_REFERENCES_10:
	.long	L_OBJC_METH_VAR_NAME_10
	.align 2
L_OBJC_SELECTOR_REFERENCES_11:
	.long	L_OBJC_METH_VAR_NAME_11
.data
.objc_module_info
	.align 2
L_OBJC_MODULES:
	.long	5
	.long	16
	.long	L_OBJC_CLASS_NAME_0
	.long	L_OBJC_SYMBOLS
	.lazy_reference .objc_class_name_NSFileManager
.data
.objc_cls_refs
	.align 2
L_OBJC_CLASS_REFERENCES_0:
	.long	L_OBJC_CLASS_NAME_1
	.lazy_reference .objc_class_name_NSCharacterSet
	.align 2
L_OBJC_CLASS_REFERENCES_1:
	.long	L_OBJC_CLASS_NAME_2
.data
.objc_class_names
	.align 2
L_OBJC_CLASS_NAME_0:
	.ascii "sorting.m\0"
	.align 2
L_OBJC_CLASS_NAME_1:
	.ascii "NSFileManager\0"
	.align 2
L_OBJC_CLASS_NAME_2:
	.ascii "NSCharacterSet\0"
.data
.objc_meth_var_names
	.align 2
L_OBJC_METH_VAR_NAME_0:
	.ascii "defaultManager\0"
	.align 2
L_OBJC_METH_VAR_NAME_1:
	.ascii "fileAttributesAtPath:traverseLink:\0"
	.align 2
L_OBJC_METH_VAR_NAME_2:
	.ascii "objectForKey:\0"
	.align 2
L_OBJC_METH_VAR_NAME_3:
	.ascii "setObject:forKey:\0"
	.align 2
L_OBJC_METH_VAR_NAME_4:
	.ascii "lastPathComponent\0"
	.align 2
L_OBJC_METH_VAR_NAME_5:
	.ascii "caseInsensitiveCompare:\0"
	.align 2
L_OBJC_METH_VAR_NAME_6:
	.ascii "intValue\0"
	.align 2
L_OBJC_METH_VAR_NAME_7:
	.ascii "whitespaceAndNewlineCharacterSet\0"
	.align 2
L_OBJC_METH_VAR_NAME_8:
	.ascii "invertedSet\0"
	.align 2
L_OBJC_METH_VAR_NAME_9:
	.ascii "rangeOfCharacterFromSet:\0"
	.align 2
L_OBJC_METH_VAR_NAME_10:
	.ascii "characterAtIndex:\0"
	.align 2
L_OBJC_METH_VAR_NAME_11:
	.ascii "compare:\0"
.text
	.align 2
	.globl _sortName
_sortName:
	mflr r5
	stmw r27,-20(r1)
	bcl 20,31,L4$pb
L4$pb:
	mr r27,r4
	mflr r31
	stw r5,8(r1)
	addis r4,r31,ha16(L_OBJC_SELECTOR_REFERENCES_4-L4$pb)
	stwu r1,-96(r1)
	lwz r29,lo16(L_OBJC_SELECTOR_REFERENCES_4-L4$pb)(r4)
	mr r4,r29
	bl L_objc_msgSend$stub
	mr r4,r29
	mr r28,r3
	mr r3,r27
	bl L_objc_msgSend$stub
	addis r2,r31,ha16(L_OBJC_SELECTOR_REFERENCES_5-L4$pb)
	mr r5,r3
	lwz r4,lo16(L_OBJC_SELECTOR_REFERENCES_5-L4$pb)(r2)
	mr r3,r28
	lwz r2,104(r1)
	addi r1,r1,96
	lmw r27,-20(r1)
	mtlr r2
	b L_objc_msgSend$stub
	.align 2
	.globl _sortModified
_sortModified:
	mflr r2
	stmw r23,-36(r1)
	bcl 20,31,L5$pb
L5$pb:
	stw r2,8(r1)
	mflr r31
	stwu r1,-112(r1)
	addis r23,r31,ha16(L_OBJC_SELECTOR_REFERENCES_2-L5$pb)
	mr r25,r5
	lwz r30,lo16(L_OBJC_SELECTOR_REFERENCES_2-L5$pb)(r23)
	mr r24,r4
	mr r5,r3
	mr r26,r3
	mr r4,r30
	mr r3,r25
	bl L_objc_msgSend$stub
	mr r4,r30
	mr r27,r3
	mr r5,r24
	mr r3,r25
	bl L_objc_msgSend$stub
	cmpwi cr0,r27,0
	mr r28,r3
	bne+ cr0,L32
	addis r7,r31,ha16(L_OBJC_CLASS_REFERENCES_0-L5$pb)
	addis r3,r31,ha16(L_OBJC_SELECTOR_REFERENCES_0-L5$pb)
	lwz r4,lo16(L_OBJC_SELECTOR_REFERENCES_0-L5$pb)(r3)
	addis r6,r31,ha16(L_NSFileModificationDate$non_lazy_ptr-L5$pb)
	lwz r5,lo16(L_NSFileModificationDate$non_lazy_ptr-L5$pb)(r6)
	lwz r3,lo16(L_OBJC_CLASS_REFERENCES_0-L5$pb)(r7)
	lwz r27,0(r5)
	bl L_objc_msgSend$stub
	mr r5,r26
	addis r2,r31,ha16(L_OBJC_SELECTOR_REFERENCES_1-L5$pb)
	li r6,1
	lwz r4,lo16(L_OBJC_SELECTOR_REFERENCES_1-L5$pb)(r2)
	bl L_objc_msgSend$stub
	mr r4,r30
	mr r5,r27
	bl L_objc_msgSend$stub
	mr. r30,r3
	beq- cr0,L33
	addis r8,r31,ha16(L_OBJC_SELECTOR_REFERENCES_3-L5$pb)
	mr r6,r26
	lwz r4,lo16(L_OBJC_SELECTOR_REFERENCES_3-L5$pb)(r8)
	mr r3,r25
	mr r5,r30
	bl L_objc_msgSend$stub
L33:
	mr r27,r30
L32:
	cmpwi cr0,r28,0
	bne+ cr0,L35
	addis r12,r31,ha16(L_OBJC_CLASS_REFERENCES_0-L5$pb)
	addis r11,r31,ha16(L_NSFileModificationDate$non_lazy_ptr-L5$pb)
	lwz r10,lo16(L_NSFileModificationDate$non_lazy_ptr-L5$pb)(r11)
	addis r28,r31,ha16(L_OBJC_SELECTOR_REFERENCES_0-L5$pb)
	lwz r3,lo16(L_OBJC_CLASS_REFERENCES_0-L5$pb)(r12)
	lwz r4,lo16(L_OBJC_SELECTOR_REFERENCES_0-L5$pb)(r28)
	lwz r26,0(r10)
	bl L_objc_msgSend$stub
	mr r5,r24
	addis r9,r31,ha16(L_OBJC_SELECTOR_REFERENCES_1-L5$pb)
	li r6,1
	lwz r4,lo16(L_OBJC_SELECTOR_REFERENCES_1-L5$pb)(r9)
	bl L_objc_msgSend$stub
	lwz r4,lo16(L_OBJC_SELECTOR_REFERENCES_2-L5$pb)(r23)
	mr r5,r26
	bl L_objc_msgSend$stub
	mr. r30,r3
	beq- cr0,L36
	addis r23,r31,ha16(L_OBJC_SELECTOR_REFERENCES_3-L5$pb)
	mr r3,r25
	lwz r4,lo16(L_OBJC_SELECTOR_REFERENCES_3-L5$pb)(r23)
	mr r6,r24
	mr r5,r30
	bl L_objc_msgSend$stub
L36:
	mr r28,r30
L35:
	lwz r24,120(r1)
	addis r25,r31,ha16(L_OBJC_SELECTOR_REFERENCES_11-L5$pb)
	lwz r4,lo16(L_OBJC_SELECTOR_REFERENCES_11-L5$pb)(r25)
	addi r1,r1,112
	mtlr r24
	mr r3,r27
	mr r5,r28
	lmw r23,-36(r1)
	b L_objc_msgSend$stub
	.align 2
	.globl _sortCreated
_sortCreated:
	mflr r2
	stmw r23,-36(r1)
	bcl 20,31,L6$pb
L6$pb:
	stw r2,8(r1)
	mflr r31
	stwu r1,-112(r1)
	addis r23,r31,ha16(L_OBJC_SELECTOR_REFERENCES_2-L6$pb)
	mr r25,r5
	lwz r30,lo16(L_OBJC_SELECTOR_REFERENCES_2-L6$pb)(r23)
	mr r24,r4
	mr r5,r3
	mr r26,r3
	mr r4,r30
	mr r3,r25
	bl L_objc_msgSend$stub
	mr r4,r30
	mr r27,r3
	mr r5,r24
	mr r3,r25
	bl L_objc_msgSend$stub
	cmpwi cr0,r27,0
	mr r28,r3
	bne+ cr0,L39
	addis r7,r31,ha16(L_OBJC_CLASS_REFERENCES_0-L6$pb)
	addis r3,r31,ha16(L_OBJC_SELECTOR_REFERENCES_0-L6$pb)
	lwz r4,lo16(L_OBJC_SELECTOR_REFERENCES_0-L6$pb)(r3)
	addis r6,r31,ha16(L_NSFileCreationDate$non_lazy_ptr-L6$pb)
	lwz r5,lo16(L_NSFileCreationDate$non_lazy_ptr-L6$pb)(r6)
	lwz r3,lo16(L_OBJC_CLASS_REFERENCES_0-L6$pb)(r7)
	lwz r27,0(r5)
	bl L_objc_msgSend$stub
	mr r5,r26
	addis r2,r31,ha16(L_OBJC_SELECTOR_REFERENCES_1-L6$pb)
	li r6,1
	lwz r4,lo16(L_OBJC_SELECTOR_REFERENCES_1-L6$pb)(r2)
	bl L_objc_msgSend$stub
	mr r4,r30
	mr r5,r27
	bl L_objc_msgSend$stub
	mr. r30,r3
	beq- cr0,L40
	addis r8,r31,ha16(L_OBJC_SELECTOR_REFERENCES_3-L6$pb)
	mr r6,r26
	lwz r4,lo16(L_OBJC_SELECTOR_REFERENCES_3-L6$pb)(r8)
	mr r3,r25
	mr r5,r30
	bl L_objc_msgSend$stub
L40:
	mr r27,r30
L39:
	cmpwi cr0,r28,0
	bne+ cr0,L42
	addis r12,r31,ha16(L_OBJC_CLASS_REFERENCES_0-L6$pb)
	addis r11,r31,ha16(L_NSFileCreationDate$non_lazy_ptr-L6$pb)
	lwz r10,lo16(L_NSFileCreationDate$non_lazy_ptr-L6$pb)(r11)
	addis r28,r31,ha16(L_OBJC_SELECTOR_REFERENCES_0-L6$pb)
	lwz r3,lo16(L_OBJC_CLASS_REFERENCES_0-L6$pb)(r12)
	lwz r4,lo16(L_OBJC_SELECTOR_REFERENCES_0-L6$pb)(r28)
	lwz r26,0(r10)
	bl L_objc_msgSend$stub
	mr r5,r24
	addis r9,r31,ha16(L_OBJC_SELECTOR_REFERENCES_1-L6$pb)
	li r6,1
	lwz r4,lo16(L_OBJC_SELECTOR_REFERENCES_1-L6$pb)(r9)
	bl L_objc_msgSend$stub
	lwz r4,lo16(L_OBJC_SELECTOR_REFERENCES_2-L6$pb)(r23)
	mr r5,r26
	bl L_objc_msgSend$stub
	mr. r30,r3
	beq- cr0,L43
	addis r23,r31,ha16(L_OBJC_SELECTOR_REFERENCES_3-L6$pb)
	mr r3,r25
	lwz r4,lo16(L_OBJC_SELECTOR_REFERENCES_3-L6$pb)(r23)
	mr r6,r24
	mr r5,r30
	bl L_objc_msgSend$stub
L43:
	mr r28,r30
L42:
	lwz r24,120(r1)
	addis r25,r31,ha16(L_OBJC_SELECTOR_REFERENCES_11-L6$pb)
	lwz r4,lo16(L_OBJC_SELECTOR_REFERENCES_11-L6$pb)(r25)
	addi r1,r1,112
	mtlr r24
	mr r3,r27
	mr r5,r28
	lmw r23,-36(r1)
	b L_objc_msgSend$stub
	.align 2
	.globl _sortKind
_sortKind:
	li r3,0
	blr
.data
.picsymbol_stub
L_objc_msgSend_stret$stub:
	.indirect_symbol _objc_msgSend_stret
	mflr r0
	bcl 20,31,L0$_objc_msgSend_stret
L0$_objc_msgSend_stret:
	mflr r11
	addis r11,r11,ha16(L_objc_msgSend_stret$lazy_ptr-L0$_objc_msgSend_stret)
	mtlr r0
	lwz r12,lo16(L_objc_msgSend_stret$lazy_ptr-L0$_objc_msgSend_stret)(r11)
	mtctr r12
	addi r11,r11,lo16(L_objc_msgSend_stret$lazy_ptr-L0$_objc_msgSend_stret)
	bctr
.data
.lazy_symbol_pointer
L_objc_msgSend_stret$lazy_ptr:
	.indirect_symbol _objc_msgSend_stret
	.long dyld_stub_binding_helper
.data
.picsymbol_stub
L_objc_msgSend$stub:
	.indirect_symbol _objc_msgSend
	mflr r0
	bcl 20,31,L0$_objc_msgSend
L0$_objc_msgSend:
	mflr r11
	addis r11,r11,ha16(L_objc_msgSend$lazy_ptr-L0$_objc_msgSend)
	mtlr r0
	lwz r12,lo16(L_objc_msgSend$lazy_ptr-L0$_objc_msgSend)(r11)
	mtctr r12
	addi r11,r11,lo16(L_objc_msgSend$lazy_ptr-L0$_objc_msgSend)
	bctr
.data
.lazy_symbol_pointer
L_objc_msgSend$lazy_ptr:
	.indirect_symbol _objc_msgSend
	.long dyld_stub_binding_helper
.data
.non_lazy_symbol_pointer
L_NSFileCreationDate$non_lazy_ptr:
	.indirect_symbol _NSFileCreationDate
	.long	0
L_NSFileModificationDate$non_lazy_ptr:
	.indirect_symbol _NSFileModificationDate
	.long	0
L__DefaultRuneLocale$non_lazy_ptr:
	.indirect_symbol __DefaultRuneLocale
	.long	0
