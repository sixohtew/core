<?php
/**
 * Copyright (c) 2012 Robin Appelman <icewind@owncloud.com>
 * This file is licensed under the Affero General Public License version 3 or
 * later.
 * See the COPYING-README file.
 */

namespace Test\Files\Utils;

use OC\Files\Utils\FileUtils;

/**
 * Class ScannerTest
 *
 * @package Test\Files\Utils
 */
class FileUtilsSTest extends \Test\TestCase {

	/**
	 * @dataProvider dataTestIsPartialFile
	 *
	 * @param string $path
	 * @param bool $expected
	 */
	public function testIsPartialFile($path, $expected) {
		$this->assertSame($expected,
			FileUtils::isPartialFile($path)
		);
	}

	public function dataTestIsPartialFile() {
		return [
			['foo.txt.part', true],
			['/sub/folder/foo.txt.part', true],
			['/sub/folder.part/foo.txt', true],
			['foo.txt', false],
			['/sub/folder/foo.txt', false],
		];
	}
}
