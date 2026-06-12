CC := abc
CFLAGS += -O3 
DEPFLAGS += -MD -MF $(dep.dir)/$(<F).d \
	    -MT $(@:$(cpp.dir)/%.abc_cpp=$(obj.dir)/%.o) -MP

ulm.isa := simple
ulm.tools := $(ulm.isa)/ulm $(ulm.isa)/ulmas $(ulm.isa)/udb-tui

LDFLAGS += 

dep.dir := dep
obj.dir := obj

xsrc.abc := $(wildcard xtest_*.abc)
src.abc := $(filter-out $(xsrc.abc),$(wildcard *.abc))

obj.abc := $(src.abc:%.abc=$(obj.dir)/%.o)
xobj := $(xsrc.abc:%.abc=$(obj.dir)/%.o)
ll.abc := $(src.abc:%.abc=%.ll)
target := $(patsubst %.abc,%,$(xsrc.abc))

dep := $(src.abc:%=$(dep.dir)/%.d) \
       $(xsrc.abc:%=$(dep.dir)/%.d)

.DEFAULT_GOAL := all

.PHONY: all
all: $(target) $(xobj) $(ulm.tools)

$(ulm.tools) : $(ulm.isa).isa
	ulm-generator --install $(ulm.isa).isa

%.ll : %.abc
	$(CC) --emit-llvm $(CFLAGS) $<

$(obj.dir)/%.o : %.abc | $(obj.dir) $(dep.dir)
	$(CC) -c $(CFLAGS) $(DEPFLAGS) $< -o $@

x% : $(obj.dir)/x%.o
x% : $(obj.dir)/x%.o $(obj.abc)
	$(LINK.o) $^ -o $@

$(dep.dir): ; mkdir -p $@
$(obj.dir): ; mkdir -p $@

.PHONY: tree.tex
tree.tex: xtest_parser
	@echo '\\documentclass[preview, margin=0.2cm]{standalone}' > tree.tex
	@echo '\\usepackage{forest}' >> tree.tex
	@echo '\\begin{document}' >> tree.tex
	@echo '\\begin{forest}' >> tree.tex
	@echo 'Type an expression (use Control-D for EOI):'
	./xtest_parser >> tree.tex
	@echo '\\end{forest}' >> tree.tex
	@echo '\\end{document}' >> tree.tex
	@echo "run 'lualatex tree.tex' to generate 'tree.pdf'"

.PHONY: clean
clean:
	$(RM) $(target)
	$(RM) -rf $(dep.dir) $(obj.dir)

$(dep):
-include $(dep)
