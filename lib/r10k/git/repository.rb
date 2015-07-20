
module R10K
	module Git
		module Repository

			# Determine if repo has been cloned into a specific dir
	        # @return [true, false] If the repo has already been cloned
	        def cloned?
	        	@is_cloned
	        end

	        def checkedout?
	        	@is_checkedout
	        end

	        def reset_remote_to_ssh
	        	if @remote.to_s.include?("http://") or @remote.to_s.include?("https://")	        		
	        		new_remote = @remote.gsub(/(http:\/\/)|(https:\/\/)/, "git@").sub("/", ":")
	        		%x[cd #{@clone_dir}; git remote rm origin; git remote add origin #{new_remote}  > /dev/null 2>&1]
	        		if $?.success?
	        			@remote = new_remote
	        		else
	        			raise "Failed to reset remote from HTTP to SSH"
	        		end
	        	end
	        	return true
	        end

	        def commits
	        	%x[cd #{@clone_dir}; git pull] # need to pull before getting all commits
	        	(%x[cd #{@clone_dir}; git rev-list --all]).split("\n")
	        end

	        def checkout_commit(commit_num)
	        	%x[cd #{@clone_dir}; git rev-parse "#{commit_num}^{commit}"  > /dev/null 2>&1]
	        	if $?.success?
	        		%x[cd #{@clone_dir}; git reset --hard #{commit_num}  > /dev/null 2>&1]
	        		return $?.success?
	        	end
	        	return false
	        end

	        def branches
	        	%x[cd #{@clone_dir}; git pull] # need to pull before getting all branches
	        	return (%x[cd #{@clone_dir}; git branch -a]).split("\n").map{|br| br.strip.split("/").last}
	        end

	        def checkout_branch(branch_name="master")
	        	if branches.include? branch_name
	        		%x[cd #{@clone_dir}; git checkout #{branch_name}  > /dev/null 2>&1]
	        		return $?.success?
	        	end
	        	return false
	        end

	        def tags
	        	%x[cd #{@clone_dir}; git pull] # need to pull before getting all tags
	        	return (%x[cd #{@clone_dir}; git tag]).split("\n").map{|tag| tag.strip}
	        end

	        def checkout_tag(tag_name="")
	        	if tags.include? tag_name
	        		%x[cd #{@clone_dir}; git checkout refs/tags/#{tag_name} > /dev/null 2>&1]
	        		return $?.success?
	        	end
	        	return false
	        end

	        def checkout
	        	@is_checkedout = checkout_tag @ref
	        	@is_checkedout ||= checkout_branch @ref
	        	@is_checkedout ||= checkout_commit @ref
	        	raise("Invalid reference") unless @is_checkedout
	        	@is_checkedout
	        end

	        def create_new_remote_branch(branch_name)
	        	return false if !cloned? or !(!@is_checkedout ? checkout : true)
	        	%x[cd #{@clone_dir}; git branch #{branch_name} > /dev/null 2>&1]
	        	if $?.success?
	        		%x[cd #{@clone_dir}; git push origin #{branch_name} --force > /dev/null 2>&1]
	        		return  $?.success?
	        	end
	        	return false
	        end

	        def delete_remote_branch(branch_name)
	        	return false if !cloned?
	        	%x[cd #{@clone_dir}; git branch #{branch_name} > /dev/null 2>&1]
	        	if $?.success?
	        		%x[cd #{@clone_dir}; git push origin --delete  #{branch_name} --force > /dev/null 2>&1]
	        		return  $?.success?
	        	end
	        end

	        def delete_clone_dir
	        	if !@clone_dir.to_s.empty? and File.directory? @clone_dir
	        		FileUtils.rm_rf(@clone_dir)
	        	end
	        end
    	end
	end
end