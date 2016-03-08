def directory_size(path)
  path << '/' unless path.end_with?('/')

  raise RuntimeError, "#{path} is not a directory" unless File.directory?(path)

  total_size = 0
  Dir["#{path}**/*"].each do |f|
    total_size += File.size(f) if File.file?(f) && File.size?(f)
  end
  total_size
end

def sanitize_filename(filename)

  ans = filename.gsub(/^.*(\\|\/)/, '')

  # Strip out the non-ascii character
  ans = ans.gsub(/[^0-9A-Za-z.\-]/, '_')

  return ans
end
