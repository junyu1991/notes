#!/usr/bin/env python
#!encoding:utf-8

import logging
import logging.config

warning_message = 'Warning message'
info_message = 'Info message'
debug_message = 'Debug message'
error_message = 'Error message'
critical_message = 'Critical message'

def normal_log():
    logging.warning(warning_message)
    logging.info(info_message)
    logging.debug(debug_message)
    logging.error(error_message)
    logging.critical(critical_message)

def logging_to_file():
    logging.basicConfig(filename="example.log", level=logging.DEBUG)
    logging.debug(debug_message)
    logging.info(info_message)
    logging.error(error_message)
    logging.warning(warning_message)
    logging.critical(critical_message)

def logging_config():
    logging.basicConfig(format='%(levelname)s-[%asctime]s:%(message)s', datefmt='%m/%d/%Y %I:%M:%S %p', level=logging.DEBUG)
    logging.debug(debug_message)
    logging.info(info_message)
    logging.warning(warning_message)
    logging.error(error_message)
    logging.critical(critical_message)

def logging_config_from_file(logging_conf):
    logging.config.fileConfig(logging_conf)
    logger = logging.getLogger('simpleExample')
    logger.debug(debug_message)
    logger.info(info_message)
    logger.warning(warning_message)
    logger.error(error_message)
    logger.critical(critical_message)

if __name__ == '__main__':
    logging_config_from_file('./logging.conf')
    normal_log()
    logging_to_file()
    logging_config()


