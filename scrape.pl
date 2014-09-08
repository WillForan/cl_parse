#!/usr/bin/env perl
use v5.18.0; use strict; use warnings;

use URI; use Web::Scraper;

use Data::Dumper;

my $cl = scraper {
  process "p.row", "car[]" => scraper {
   process "span.price", price => 'TEXT';
   process "span.pnr>small", where => 'TEXT';
   process "span.date", when => 'TEXT';
   process "span.pl>a", posttitle => 'TEXT';
   process "span.pl>a", url => '@href';
  };
};

my $info = scraper {
 process "p.attrgroup>span", "info[]" => scraper {
  process ".", item => 'TEXT';
  process "span>b", value => 'TEXT';
 };
};

my $baseurl = "http://pittsburgh.craigslist.org/";
my $min=1000;
my $searchURL="${baseurl}search/sss?query=honda+fit&minAsk=$min&sort=rel";

my $res= $cl->scrape(URI->new($searchURL));
my @columns=qw/year price when where title_status color transmission odometer posttitle url/;
say join("\t",@columns);

for my $post (@{$res->{car}}) {
 next unless $post->{url};
 next unless $post->{posttitle} =~ /honda.*fit/i;
 $post->{url}=$baseurl.$post->{url} unless $post->{url} =~ /http/;
 $post->{where} =~s/[()	]//g;
 $post->{where} = $& if $post->{where} =~ /(\S+\s+){2}/;
 $post->{price} =~s/[\$,]//g;
 $post->{year} = $2 if $post->{posttitle} =~/(20|19)?(\d{2})/;
 #say $post->{url}, "\n", $post->{posttitle};


 my $thisinfo = $info->scrape(URI->new($post->{url}));

 for(@{$thisinfo->{info}}){
  $_->{item}="car" if $_->{item} eq $_->{value};
  $_->{item}="color" if $_->{item} =~/color/i;
  $_->{item} =~ s/\s*:.*//;
  $_->{item} =~ s/\s+/_/;
  $post->{$_->{item}}=$_->{value};
 };

 say join("\t", map {s/'//g; $_||"NA"} @{$post}{@columns});
 
}
