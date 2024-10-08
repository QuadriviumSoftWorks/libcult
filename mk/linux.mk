
LIBCULT_LIB:=$(L)/libcult.a
LIBCULT_OBJ:=\
	$(O)/linux-amd64-ops.o $(O)/linux-amd64-api.o

LIBCULT_TST:=\
	$(T)/libcult-convert \
	$(T)/libcult-create \

$(LIBCULT_LIB): $(LIBCULT_OBJ) | $(L)
	$(AR) rcs $@ $^

$(O)/linux-amd64-ops.o: src/linux/amd64/ops.S | $(O) $(D)
	$(CC) -c $< -o $@
$(O)/linux-amd64-api.o: src/linux/amd64/api.c | $(O) $(D)
	$(CC) $(ALL_CFLAGS) $(ALL_CPPFLAGS) -MMD -MF $(D)/api.d -c $< -o $@

$(T)/libcult-convert: $(O)/tests-libcult-convert.o | $(T) $(L)/libcult.a
	$(CC) $(ALL_LDFLAGS) -o $@ $^ -lcult
$(O)/tests-libcult-convert.o: tst/libcult-convert.c | $(O) $(D)
	$(CC) $(ALL_CFLAGS) $(ALL_CPPFLAGS) -MMD -MF $(D)/tests-libcult-convert.d -c $< -o $@

$(T)/libcult-create: $(O)/tests-libcult-create.o | $(T) $(L)/libcult.a
	$(CC) $(ALL_LDFLAGS) -o $@ $^ -lcult
$(O)/tests-libcult-create.o: tst/libcult-create.c | $(O) $(D)
	$(CC) $(ALL_CFLAGS) $(ALL_CPPFLAGS) -MMD -MF $(D)/tests-libcult-create.d -c $< -o $@

