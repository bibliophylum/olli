-- 14-social-media.sql

create sequence social_media_id_seq;

create table social_media (
       id integer not null default nextval('social_media_id_seq'::regclass),
       branch_id integer not null,
       is_confirmed boolean default true, -- false == data needs review
       has_facebook boolean default false,
       facebook_handle text,
       facebook_followers integer,
       facebook_posts integer,
       has_twitter boolean default false,
       twitter_handle text,
       twitter_followers integer,
       twitter_posts integer,
       has_flickr boolean default false,
       flickr_handle text,
       flickr_followers integer,
       flickr_posts integer,
       has_blog boolean default false,
       blog_handle text,
       blog_followers integer,
       blog_posts integer,
       has_google_plus boolean default false,
       google_plus_handle text,
       google_plus_followers integer,
       google_plus_posts integer,
       has_youtube boolean default false,
       youtube_handle text,
       youtube_followers integer,
       youtube_posts integer,
       has_pinterest boolean default false,
       pinterest_handle text,
       pinterest_followers integer,
       pinterest_posts integer,
       has_instagram boolean default false,
       instagram_handle text,
       instagram_followers integer,
       instagram_posts integer,
       has_other_1 boolean default false,
       other_1_handle text,
       other_1_followers integer,
       other_1_posts integer,
       has_other_2 boolean default false,
       other_2_handle text,
       other_2_followers integer,
       other_2_posts integer,
       has_other_3 boolean default false,
       other_3_handle text,
       other_3_followers integer,
       other_3_posts integer,
       primary key(id)
);

alter table social_media add foreign key (branch_id) references branches (id);
create index on social_media (branch_id);
