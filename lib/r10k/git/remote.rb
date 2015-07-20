require 'fileutils'
require "r10k/git/repository"
module R10K
    module Git
        class Remote

            include R10K::Git::Repository

            # @!attribute [r] remote
            # @return [String] The URL to the remote git repository
            attr_reader :remote

            # @!attribute [r] ref
            # @return [String] The git reference to clone
            attr_reader :ref

            # @!attribute [r] clone_dir
            # @return [String] Directory path to clone
            attr_reader :clone_dir

            # @!attribute [r] is_cloned
            # @return [Boolean] Return true/false based on repository clonded status
            attr_reader :is_cloned

            # @!attribute [r] is_checkedout
            # @return [Boolean] Return true/false based on repository reference checkedout status
            attr_accessor :is_checkedout

            # @param remote  [String]
            # @param ref     [String]
            # @param clone_dir [String]
            def initialize(remote, ref, clone_dir)
                raise("Must provide remote git URL") if (remote.to_s.empty?)
                raise("Must provide branch name or commit number or tag name as ref") if (ref.to_s.empty?)
                raise("Must provide directoy name to clone") if (clone_dir.to_s.empty?)
                @remote  = remote
                @clone_dir = clone_dir
                if  File.directory? @clone_dir
                    FileUtils.rm_rf(@clone_dir)
                end
                @ref = ref
                @is_checkedout = false
                @is_cloned = self.clone
                #       @is_checkedout = self.checkout if @is_cloned
                unless @is_cloned
                    FileUtils.rm_rf(@clone_dir)
                    raise("Invalid remote '#{@remote}' or reference '#{@ref}' ")
                end
                #       raise("Invalid reference") unless @is_checkedout
                reset_remote_to_ssh
            end

            def clone
                %x[git clone #{remote} #{@clone_dir}  > /dev/null 2>&1]
                return $?.success?
            end
        end
    end
end
