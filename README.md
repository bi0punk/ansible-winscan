# ansible-winscan

Ansible playbook to scan Windows hosts for security vulnerabilities and potential backdoors using PowerShell scripts.

[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![CI](https://github.com/tu-usuario/ansible-winscan/actions/workflows/ci.yml/badge.svg)](https://github.com/tu-usuario/ansible-winscan/actions/workflows/ci.yml)

## Tabla de Contenidos

- [Características](#características)
- [Stack](#stack)
- [Arquitectura](#arquitectura)
- [Requisitos](#requisitos)
- [Instalación](#instalación)
- [Uso](#uso)
- [Tests](#tests)
- [Configuración](#configuración)
- [CI](#ci)
- [Limitaciones / Roadmap](#limitaciones--roadmap)
- [Licencia](#licencia)

## Características

- Escaneo automatizado de hosts Windows via Ansible
- Detección de vulnerabilidades y configuraciones inseguras
- Scripts PowerShell para auditoría de seguridad
- Inventario YAML flexible para targets
- Roles reutilizables para diferentes tipos de escaneo

## Stack

- Ansible, YAML, PowerShell

## Arquitectura

```
ansible-winscan/
├── inventory.yml           # Inventario de hosts Windows
├── scan_windows.yml        # Playbook principal
├── collections/            # Colecciones Ansible
├── roles/
│   └── scan/
│       ├── tasks/
│       ├── files/
│       └── templates/
├── tests/
├── .env.example
├── .github/workflows/ci.yml
└── README.md
```

## Requisitos

- Nodo de control Ansible (Linux)
- Windows hosts con WinRM habilitado
- PowerShell Execution Policy configurada

## Instalación

```bash
git clone https://github.com/tu-usuario/ansible-winscan.git
cd ansible-winscan

# Instalar colecciones necesarias
ansible-galaxy collection install -r collections/requirements.yml
```

## Uso

```bash
# Editar inventario con tus hosts Windows
vim inventory.yml

# Ejecutar playbook de escaneo
ansible-playbook scan_windows.yml

# Escaneo específico por tag
ansible-playbook scan_windows.yml --tags security
```

## Tests

```bash
# Validar sintaxis del playbook
ansible-playbook --syntax-check scan_windows.yml
```

## Configuración

Variables de entorno (ver `.env.example`):

| Variable          | Descripción                    |
|-------------------|--------------------------------|
| `ANSIBLE_USER`    | Usuario WinRM                  |
| `ANSIBLE_PASS`    | Contraseña WinRM               |
| `WINRM_PORT`      | Puerto WinRM (default 5985)    |

## CI

GitHub Actions ejecuta validación de sintaxis Ansible en cada push y PR.

## Limitaciones / Roadmap

- [ ] Añadir más checks de seguridad (CIS benchmarks)
- [ ] Generación de reportes HTML
- [ ] Integración con SIEM
- [ ] Tests con molecule + vagrant

## Licencia

MIT
