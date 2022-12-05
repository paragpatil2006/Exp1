#!/usr/bin/env ruby
require 'fileutils'

  # Runs the given shell command. This is a simple wrapper around Kernel#system.
  def run_shell_cmd(args)
    system(*args)
  end

  @org = ARGV[0]
  @repo_name = ARGV[1]
  @compression = ARGV[2]
  @branch = ARGV[3]
  @pwd = `pwd`.chop
  @token = ARGV[4]
  @tmp = /tmp
  @syftpath = syft

  Dir.chdir @pwd
  cmd = "curl -H 'Authorization: token #{@token}' -L 'https://github.com/#{@org}/#{@repo_name}/#{@compression}/#{@branch}' | tar x -C '#{@tmp}'"

  puts "  "
  puts " "
  puts "================================"
  puts "Getting source code from github"
  run_shell_cmd cmd
  Dir.chdir "#{@tmp}/#{@org}-#{@repo_name}-#{@branch}"
  @pwd   = `pwd`.chop
  puts "  "
  puts " "
  puts "================================"

  cmd = "docker build -t '#{@repo_name}' ."
  puts "Generating docker image"
  run_shell_cmd cmd

  puts "  "
  puts " "
  puts "================================"


  cmd = "'#{@syftpath}' -o table '#{@repo_name}' > sbom.table"
  #cmd = "'#{@syftpath}' -o spdx-json  '#{@repo_name}' > sbom-spdx.json"
  puts "Generating SBOM"
  run_shell_cmd cmd
  puts "  "
  puts "======================= See SBOM below ============================ "
  puts "===================================================================="

  cmd = "cat sbom.table"
  run_shell_cmd cmd
  
  puts "  "
  puts " "
  puts "================================"

  cmd = "docker rmi  '#{@repo_name}'"
  puts "Cleaning up the container"
  run_shell_cmd cmd 
