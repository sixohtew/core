<?php
/**
 * @author Viktar Dubiniuk <dubiniuk@owncloud.com>
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

namespace OCA\FederatedFileSharing;

/**
 * Class Address
 *
 * @package OCA\FederatedFileSharing
 */
class Address {
	/**
	 * @var string
	 */
	protected $userId;

	/**
	 * @var string
	 */
	protected $displayName;

	/**
	 * @var string
	 */
	protected $hostName;

	/**
	 * Address constructor.
	 *
	 * @param string $hostName
	 * @param string $userId
	 * @param string $displayName
	 */
	public function __construct($hostName, $userId, $displayName = '') {
		$this->hostName = $hostName;
		$this->userId = $userId;
		$this->displayName = $displayName;
	}

	/**
	 * Get user federated id
	 *
	 * @return string
	 */
	public function getCloudId() {
		return "{$this->userId}@{$this->hostName}";
	}

	/**
	 * Get user id
	 *
	 * @return string
	 */
	public function getUserId() {
		return $this->userId;
	}

	/**
	 * Get user host
	 *
	 * @return string
	 */
	public function getHostName() {
		return $this->hostName;
	}

	/**
	 * Get user display name, fallback to userId if it is empty
	 *
	 * @return string
	 */
	public function getDisplayName() {
		return ($this->displayName !== '') ? $this->displayName : $this->userId;
	}
}
