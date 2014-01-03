require "json"
require "rugged"
require "open3"

module RevisioneerNotify
  class Base
    attr_reader :host, :api_token, :path
    def initialize host, token, path
      @host = host
      @api_token = token
      @path = path
    end

    def last_deploy
      @last_deploy ||= begin
        curl = %Q{curl "#{host}/deployments?limit=1" -H "API-TOKEN: #{api_token}" -s}
        response = %x[#{curl}].strip
        JSON.parse(response).first || {}
      end
    rescue => err
      {} # no JSON received - propably first deploy?
    end

    def number_of_new_commits
      walker = Rugged::Walker.new(repo)
      walker.push sha
      walker.hide last_deploy_sha if last_deploy_sha
      walker.each.to_a.count
    end

    def last_deploy_date
      Time.parse(last_deploy.fetch("deployed_at"))
    end

    def last_deploy_sha
      last_deploy.fetch("sha", nil)
    end

    def repo
      @repo ||= Rugged::Repository.new(path)
    end

    def messages
      [] # implemented in subclass
    end

    def notify!
      payload = {
        "sha" => sha,
        "messages" => messages,
        "new_commit_counter" => number_of_new_commits
      }
      %x[curl -X POST #{host}/deployments -d '#{JSON.dump(payload)}' -H 'API-TOKEN: #{api_token}' -H 'Content-Type: application/json' -s]
    end

    def sha
      ref = repo.head
      ref.target
    end
  end
end