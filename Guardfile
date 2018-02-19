guard :minitest, include: %w(test), all_after_pass: true do
  watch(%r{^test/(.*)\/?(.*)_test\.rb$})
  watch(%r{^lib/(.*/)?([^/]+)\.rb$})     {  |m| "test/#{m[1]}#{m[2]}_test.rb"}
  watch(%r{^test/test_helper\.rb$})      { 'test' }
end
