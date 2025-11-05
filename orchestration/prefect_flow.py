from prefect import flow, task
import subprocess

@task
def dbt_seed():
    subprocess.run(['dbt', 'seed'], check=True)

@task
def dbt_run():
    subprocess.run(['dbt', 'run'], check=True)

@task
def dbt_test():
    subprocess.run(['dbt', 'test'], check=True)

@flow
def ucrm_daily_flow():
    dbt_seed()
    dbt_run()
    dbt_test()

if __name__ == '__main__':
    ucrm_daily_flow()
