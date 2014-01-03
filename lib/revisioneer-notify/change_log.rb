module RevisioneerNotify
  # Uses the first line of each commit message as entries to the changelog
  class ChangeLog < Base
    attr_accessor :revisioneer_inclusion, :revisioneer_exclusion

    def messages
      walker = Rugged::Walker.new(repo)
      walker.push sha
      walker.hide last_deploy_sha if last_deploy_sha
      messages = walker.each.to_a.map { |commit|
        commit.message.lines.first.strip
      }
      messages.select! { |line| line =~ revisioneer_inclusion } if revisioneer_inclusion
      messages.reject! { |line| line =~ revisioneer_exclusion } if revisioneer_exclusion
      messages
    end
  end
end