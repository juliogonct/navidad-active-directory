import logging
from logging.handlers import RotatingFileHandler
from app import app

############################################################################################################################################
# Configuración de Sistemas de Log
############################################################################################################################################

# Configuración de loggers
def setup_logger(base_name, log_dir='./logs/', level=logging.INFO, max_bytes=10000, backup_count=3):
    log_file = f"{log_dir}{base_name}.log"
    logger_name = f"{base_name}_logger"
    logger = logging.getLogger(logger_name)
    logger.setLevel(level)
    handler = RotatingFileHandler(log_file, maxBytes=max_bytes, backupCount=backup_count, encoding='utf-8')
    formatter = logging.Formatter('%(asctime)s - %(levelname)s - %(message)s')
    handler.setFormatter(formatter)
    logger.addHandler(handler)
    return logger

# Configuración de loggers específicos
unlock_account_logger = setup_logger('desbloquear_usuario')
reset_password_logger = setup_logger('restaurar_contrasena', backup_count=5)
