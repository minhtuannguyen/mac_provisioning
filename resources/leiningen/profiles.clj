{:user {:plugins             [[venantius/ultra "0.6.0"]
                              [mvxcvi/whidbey "2.2.1"]
                              [com.jakemccrary/lein-test-refresh "0.25.0"]]
        :test-refresh        {:notify-command ["tmux" "display-message"]}
        :dependencies        [[spyscope "0.1.6"]
                              [org.clojure/tools.nrepl "0.2.13"]]
        :injections          [(require 'spyscope.core)]

        :deploy-repositories [["clojars" {:url "https://clojars.org/repo/" :sign-releases false}]]
        :ultra               {:color-scheme :solarized_dark}}}
