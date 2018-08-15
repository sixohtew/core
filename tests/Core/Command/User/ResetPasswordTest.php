<?php
/**
 * @author Sujith Haridasan <sharidasan@owncloud.com>
 *
 * @copyright Copyright (c) 2018, ownCloud GmbH
 * @license AGPL-3.0
 *
 * This code is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License, version 3,
 * as published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License, version 3,
 * along with this program.  If not, see <http://www.gnu.org/licenses/>
 *
 */

namespace Tests\Core\Command\User;

use OC\Core\Command\User\ResetPassword;
use OC\Helper\EnvironmentHelper;
use OC\Mail\Message;
use OCP\AppFramework\Utility\ITimeFactory;
use OCP\IConfig;
use OCP\IL10N;
use OCP\IURLGenerator;
use OCP\IUser;
use OCP\IUserManager;
use OCP\Mail\IMailer;
use OCP\Security\ISecureRandom;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;
use Test\TestCase;

/**
 * Class ResetPasswordTest
 *
 * @group DB
 * @package Tests\Core\Command\User
 */
class ResetPasswordTest extends TestCase {
	/** @var  IUserManager | \PHPUnit_Framework_MockObject_MockObject */
	private $userManager;
	/** @var  \OC_Defaults | \PHPUnit_Framework_MockObject_MockObject */
	private $default;
	/** @var IURLGenerator | \PHPUnit_Framework_MockObject_MockObject */
	private $urlGenerator;
	/** @var  IConfig | \PHPUnit_Framework_MockObject_MockObject */
	private $config;
	/** @var  IMailer | \PHPUnit_Framework_MockObject_MockObject */
	private $mailer;
	/** @var  ISecureRandom | \PHPUnit_Framework_MockObject_MockObject */
	private $secureRandom;
	/** @var  ITimeFactory | \PHPUnit_Framework_MockObject_MockObject */
	private $timeFactory;
	/** @var  IL10N | \PHPUnit_Framework_MockObject_MockObject */
	private $l10n;
	/** @var  EnvironmentHelper | \PHPUnit_Framework_MockObject_MockObject */
	private $environmentHelper;
	/** @var  ResetPassword */
	private $resetPassword;
	protected function setUp() {
		parent::setUp();

		$this->userManager = $this->createMock(IUserManager::class);
		$this->default = $this->createMock(\OC_Defaults::class);
		$this->urlGenerator = $this->createMock(IURLGenerator::class);
		$this->config = $this->createMock(IConfig::class);
		$this->mailer = $this->createMock(IMailer::class);
		$this->secureRandom = $this->createMock(ISecureRandom::class);
		$this->timeFactory = $this->createMock(ITimeFactory::class);
		$this->l10n = $this->createMock(IL10N::class);
		$this->environmentHelper = $this->createMock(EnvironmentHelper::class);
		$this->resetPassword = new ResetPassword($this->userManager, $this->default,
			$this->urlGenerator, $this->config, $this->mailer, $this->secureRandom,
			$this->timeFactory, $this->l10n, $this->environmentHelper);
	}

	public function testResetPasswordFromEnv() {
		$input = $this->createMock(InputInterface::class);
		$output = $this->createMock(OutputInterface::class);

		$input->expects($this->once())
			->method('getArgument')
			->willReturn('foo');
		$input->expects($this->exactly(3))
			->method('getOption')
			->willReturnMap([
				['via-email', false],
				['via-link', false],
				['password-from-env', true]
			]);

		$this->environmentHelper->expects($this->once())
			->method('getEnvVar')
			->willReturn('fooPass');

		$user = $this->createMock(IUser::class);
		$user->expects($this->once())
			->method('setPassword')
			->willReturn(true);

		$this->userManager->expects($this->once())
			->method('get')
			->willReturn($user);

		$this->assertNull($this->invokePrivate($this->resetPassword, 'execute', [$input, $output]));
	}

	public function testDisplayLink() {
		$input = $this->createMock(InputInterface::class);
		$output = $this->createMock(OutputInterface::class);

		$input->expects($this->once())
			->method('getArgument')
			->willReturn('foo');

		$input->expects($this->exactly(3))
			->method('getOption')
			->willReturnMap([
				['via-email', false],
				['via-link', true],
				['password-from-env', false]
			]);

		$user = $this->createMock(IUser::class);
		$user->expects($this->exactly(2))
			->method('getUID')
			->willReturn('foo');

		$this->userManager->expects($this->once())
			->method('get')
			->willReturn($user);

		$this->secureRandom->expects($this->once())
			->method('generate')
			->willReturn('123AbcFooBar');

		$this->urlGenerator->expects($this->once())
			->method('linkToRouteAbsolute')
			->willReturn('http://localhost/foo/bar/123AbcFooBar/foo');

		$output->expects($this->once())
			->method('writeln')
			->with('The password reset link is: http://localhost/foo/bar/123AbcFooBar/foo');

		$this->invokePrivate($this->resetPassword, 'execute', [$input, $output]);
	}

	public function testEmailLink() {
		$input = $this->createMock(InputInterface::class);
		$output = $this->createMock(OutputInterface::class);

		$input->expects($this->once())
			->method('getArgument')
			->willReturn('foo');

		$input->expects($this->exactly(3))
			->method('getOption')
			->willReturnMap([
				['via-email', true],
				['via-link', false],
				['password-from-env', false]
			]);

		$user = $this->createMock(IUser::class);

		$user->expects($this->exactly(2))
			->method('getEMailAddress')
			->willReturn('foo@bar.com');

		$user->expects($this->exactly(2))
			->method('getUID')
			->willReturn('foo');

		$this->userManager->expects($this->once())
			->method('get')
			->willReturn($user);

		$this->secureRandom->expects($this->once())
			->method('generate')
			->willReturn('123AbcFooBar');

		$this->urlGenerator->expects($this->once())
			->method('linkToRouteAbsolute')
			->willReturn('http://localhost/foo/bar/123AbcFooBar/foo');

		$message = $this->createMock(Message::class);

		$message->expects($this->once())
			->method('setTo')
			->willReturn($message);
		$message->expects($this->once())
			->method('setSubject')
			->willReturn($message);
		$message->expects($this->once())
			->method('setHtmlBody')
			->willReturn($message);
		$message->expects($this->once())
			->method('setFrom')
			->willReturn($message);

		$this->mailer->expects($this->once())
			->method('send');

		$this->mailer->expects($this->once())
			->method('createMessage')
			->willReturn($message);

		$output->expects($this->once())
			->method('writeln')
			->with('The password reset link is: http://localhost/foo/bar/123AbcFooBar/foo');

		$this->assertEquals(0, $this->invokePrivate($this->resetPassword, 'execute', [$input, $output]));
	}

	public function testEmailLinkFailure() {
		$input = $this->createMock(InputInterface::class);
		$output = $this->createMock(OutputInterface::class);

		$input->expects($this->once())
			->method('getArgument')
			->willReturn('foo');

		$input->expects($this->exactly(3))
			->method('getOption')
			->willReturnMap([
				['via-email', true],
				['via-link', false],
				['password-from-env', false]
			]);

		$user = $this->createMock(IUser::class);

		$user->expects($this->once())
			->method('getEMailAddress')
			->willReturn(null);
		$user->expects($this->once())
			->method('getUID')
			->willReturn('foo');

		$this->userManager->expects($this->once())
			->method('get')
			->willReturn($user);

		$output->expects($this->once())
			->method('writeln')
			->with('<error>Email address is not set for the user foo</error>');
		$this->invokePrivate($this->resetPassword, 'execute', [$input, $output]);
	}
}
