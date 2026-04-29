#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import re
import os
import datetime
from html import escape



# Helpers

def clean_url(url: str) -> str:
	return url.rstrip(').,;')

def is_valid_url(url: str) -> bool:
	return url.startswith("http://") or url.startswith("https://")



# Core
def generate_html_bookmarks(md_filename: str, bookmarks_filename: str):

	header_stack = []
	bookmark_timestamp = int(datetime.datetime.now().timestamp())
	link_count = 0
	seen_urls = set()

	md_link_pattern = re.compile(r'\[([^\]]+)\]\((https?://[^)\s]+)\)')
	raw_url_pattern = re.compile(r'(https?://[^\s)]+)')
	header_pattern = re.compile(r'^(#+)\s+(.*)')

	with open(md_filename, 'r', encoding='utf-8') as f:
		lines = f.readlines()

	with open(bookmarks_filename, 'w', encoding='utf-8') as bm:

		bm.write('<!DOCTYPE>\n')
		bm.write('<META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=UTF-8">\n')
		bm.write('<TITLE>SEC556 IoT Resources</TITLE>\n')
		bm.write('<H1>SEC556 IoT Resources</H1>\n')
		bm.write('<DL><p>\n')

		for line in lines:

			stripped = line.strip()

			# HEADERS
			header_match = header_pattern.match(stripped)
			if header_match:
				level = len(header_match.group(1))
				title = header_match.group(2).replace("***", "").strip()

				while header_stack and header_stack[-1] >= level:
					prev = header_stack.pop()
					bm.write('    ' * (prev - 1) + '</DL><p>\n')

				header_stack.append(level)

				bm.write(
					'    ' * (level - 1)
					+ f'<DT><H3 ADD_DATE="{bookmark_timestamp}">{escape(title)}</H3>\n'
				)
				bm.write('    ' * (level - 1) + '<DL><p>\n')

				continue

			# MARKDOWN LINKS
			for match in md_link_pattern.findall(line):
				title, url = match
				url = clean_url(url)

				if not is_valid_url(url) or url in seen_urls:
					continue

				seen_urls.add(url)

				bm.write(
					'    ' * (len(header_stack))
					+ f'<DT><A HREF="{escape(url)}" ADD_DATE="{bookmark_timestamp}">'
					+ escape(title.strip())
					+ '</A>\n'
				)
				link_count += 1

			# RAW URLS
			raw_urls = raw_url_pattern.findall(line)

			for url in raw_urls:
				url = clean_url(url)

				if url in seen_urls or not is_valid_url(url):
					continue

				seen_urls.add(url)

				bm.write(
					'    ' * (len(header_stack))
					+ f'<DT><A HREF="{escape(url)}" ADD_DATE="{bookmark_timestamp}">'
					+ escape(url)
					+ '</A>\n'
				)
				link_count += 1

		# Close tags
		while header_stack:
			level = header_stack.pop()
			bm.write('    ' * (level - 1) + '</DL><p>\n')

	return link_count



# Main
def main():
	md_filename = "../README.md"
	output_filename = "bookmarks.html"

	output_path = os.path.abspath(output_filename)

	count = generate_html_bookmarks(md_filename, output_filename)

	print(f"[+] Bookmarks generated: {output_path}")
	print(f"[+] Total links: {count}")


if __name__ == "__main__":
	main()
