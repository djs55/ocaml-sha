all:
	jbuilder build --dev @install

test:
	jbuilder runtest

doc:
	jbuilder build @doc

install:
	jbuilder install

uninstall:
	jbuilder uninstall

clean:
	jbuilder clean
