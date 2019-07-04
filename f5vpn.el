;;; f5vpn.el --- Utility functions for working with f5vpn -*- lexical-binding: t -*-

;; Copyright (c) 2019 Daniel Kraus <daniel@kraus.my>

;; Author: Daniel Kraus <daniel@kraus.my>
;; URL: https://github.com/dakra/f5vpn.el
;; Keywords: f5, vpn, f5vpn, big-ip, f5fpc, convenience, tools
;; Version: 0.1
;; Package-Requires: ((emacs "25.2"))

;; This file is NOT part of GNU Emacs.

;;; License:

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; `f5vpn.el' provides functions for managing F5 (BIG IP) VPN connections.
;; The Linux command line tool `f5fpc' must be present.
;;
;; Customize `f5vpn-host' to match your host and then either set
;; `f5vpn-user', `f5vpn-pass-prefix' or put an entry in your authinfo file
;; where `machine' matches `f5vpn-host', `login' is your username and
;; `password' is you password prefix prepended to the given passcode.

;;; Code:
(require 'async)
(require 'auth-source)


;;; Customization

(defgroup f5vpn nil
  "F5 VPN"
  :prefix "f5vpn-"
  :group 'tools
  :link '(url-link "https://github.com/dakra/f5vpn.el"))

(defcustom f5vpn-exec "f5fpc"
  "Name of the f5fpc executable."
  :type 'string)

(defcustom f5vpn-host nil
  "F5 VPN hostname to connect to."
  :type 'string)

(defcustom f5vpn-user nil
  "Username used when connecting.
If NIL, get the username from authsource."
  :type 'string)

(defcustom f5vpn-pass-prefix nil
  "Pass prefix used when connecting.
If NIL, get the pass prefix from authsource (password entry).
If you don't want a prefix, set it to an empty string \"\"."
  :type 'string)



;;; Interactive commands

;;;###autoload
(defun f5vpn-connect (password)
  "Connect to F5 VPN with PASSWORD."
  (interactive (list (read-passwd "RSA SecurID: ")))
  (if-let ((plist (or f5vpn-user (car (auth-source-search :host f5vpn-host :max 1))))
           (user (or f5vpn-user (plist-get plist :user)))
           (prefix (or f5vpn-pass-prefix (funcall (plist-get plist :secret))))
           (pass (concat (or prefix "") password)))
      (async-start-process "f5vpn start" f5vpn-exec 'ignore
                           "--start"
                           "--host" f5vpn-host
                           "--user" user
                           "--password" pass)
    (error "No user / password found in authinfo")))

;;;###autoload
(defun f5vpn-disconnect ()
  "Disconnect VPN."
  (interactive)
  (async-start-process "f5vpn stop" f5vpn-exec 'ignore "--stop"))

;;;###autoload
(defun f5vpn-info ()
  "Info VPN."
  (interactive)
  (message (shell-command-to-string (format "%s --info" f5vpn-exec))))


(provide 'f5vpn)
;;; f5vpn.el ends here
