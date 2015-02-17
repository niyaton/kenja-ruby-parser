const 1
"test"
:hoge
class Hello
	def call
		p "Hello!"
	end
end

class JapaneseHello < Hello
	def call
		p "こんにちは！"
	end
end

h = Hello.new
h.call
jh = JapaneseHello.new
jh.call

def hello
	p "Hello!"
end

for i in 1..10
	hello
end
