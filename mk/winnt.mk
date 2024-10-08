
LIBCULT_LIB:=build/winnt/amd64/lib/libcult.a
LIBCULT_OBJ:=\
	$(O)/winnt-amd64-ops.o $(O)/winnt-amd64-api.o

LIBCULT_TST:=\
	$(T)/libcult-convert.exe \
	$(T)/libcult-create.exe \

$(LIBCULT_LIB): $(LIBCULT_OBJ) | $(L)
	$(AR) rcs $@ $^

$(O)/winnt-amd64-ops.o: src/winnt/amd64/ops.S | $(O) $(D)
	$(CC) -c $< -o $@
$(O)/winnt-amd64-api.o: src/winnt/amd64/api.c | $(O) $(D)
	$(CC) $(ALL_CFLAGS) $(ALL_CPPFLAGS) -MMD -MF $(D)/api.d -c $< -o $@

$(T)/libcult-convert.exe: $(O)/tests-libcult-convert.o | $(T) $(L)/libcult.a
	$(CC) $(ALL_LDFLAGS) -o $@ $^ -lcult
$(O)/tests-libcult-convert.o: tst/libcult-convert.c | $(O) $(D)
	$(CC) $(ALL_CFLAGS) $(ALL_CPPFLAGS) -MMD -MF $(D)/tests-libcult-convert.d -c $< -o $@

$(T)/libcult-create.exe: $(O)/tests-libcult-create.o | $(T) $(L)/libcult.a
	$(CC) $(ALL_LDFLAGS) -o $@ $^ -lcult
$(O)/tests-libcult-create.o: tst/libcult-create.c | $(O) $(D)
	$(CC) $(ALL_CFLAGS) $(ALL_CPPFLAGS) -MMD -MF $(D)/tests-libcult-create.d -c $< -o $@
