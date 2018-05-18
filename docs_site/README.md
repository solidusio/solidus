Based on [https://github.com/joshukraine/middleman-gulp](https://github.com/joshukraine/middleman-gulp)

Requirements
------------

* [Middleman 4.x][middleman-docs]
* [Ruby 2.x][rbenv]
* [Node 8.x][nvm]
* [Gulp CLI][gulp-cli]

Usage
-----

1. Install ruby gems `bundle install`

2. Install npm packages `npm install` 

3. Start the Middleman server. Note that this will also invoke Webpack via the external pipeline.

        $ bundle exec middleman server

4. To build html and assets for production, run

        $ bundle exec middleman build
        
5. Set proper `base_url` in config.rb         