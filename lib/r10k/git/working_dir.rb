require "r10k/git/repository"
module R10K
    module Git
        class WorkingDir

            include R10K::Git::Repository


            # @!attribute [r] ref
            #   @return [R10K::Git::Ref] The git reference to use check out in the given directory
            attr_reader :ref

            # @!attribute [r] remote
            #   @return [String] The actual remote used as an upstream for this module.
            attr_reader :remote

            attr_reader :clone_dir

            attr_reader :is_cloned


            # @param clone_dir [String]
            def initialize(clone_dir)
                @clone_dir = clone_dir
                @remote  = remote
                @ref = ref
                @is_cloned = true
                @is_checkedout = true
                reset_remote_to_ssh
            end

            def remote
                (%x[cd #{@clone_dir}; git config --get remote.origin.url])
            end

            def ref
                (%x[cd #{@clone_dir}; git rev-parse --abbrev-ref HEAD]).strip()
            end  
        end
    end
end